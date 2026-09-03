import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
import '../../main.dart';
import '../../comm/audio_tools.dart';
import '../../comm/wakelock_tools.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/comm/muyu_rhythm_store.dart';
import 'package:gongke/comm/nianfo_muyu_session_controller.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

class NianShengHaoPage extends StatefulWidget {
  const NianShengHaoPage({super.key});

  @override
  State<NianShengHaoPage> createState() => _NianShengHaoPageState();
}

class _NianShengHaoPageState extends State<NianShengHaoPage> {
  GongKeItemData? gongkeitem;
  bool isLoaded = false;
  double interval = 1.0;
  Timer? _uiTimer;

  /// 电子木鱼时间间隔持久化键（按 gongketype+name 分别存储，单位秒）
  String get _intervalKey =>
      'gongke.muyuIntervalSeconds.${gongkeitem!.gongketype}.${gongkeitem!.name}';

  late final NianFoMuyuSessionController _session;
  String _selectedPatternId = 'regular';

  @override
  void initState() {
    super.initState();
    _session = NianFoMuyuSessionController(onCompleted: () {
      WakelockTools.disable();
      _markComplete();
      if (mounted) setState(() {});
    });
  }

  Future<void> _markComplete() async {
    final item = gongkeitem;
    if (item == null) return;
    await globalDB.managers.gongKeItem
        .filter((record) => record.id.equals(item.id))
        .update((record) => record(isComplete: const Value(true)));
    await syncTaskAndCalendarCards();
  }

  /// 读取该功课上次保存的时间间隔，没有则保持默认 1.0 秒
  Future<void> _loadInterval() async {
    if (gongkeitem == null) return;
    final saved = await getDoubleValue(_intervalKey);
    if (saved != null && mounted) {
      setState(() => interval = saved);
    }
  }

  /// 持久化该功课当前时间间隔，下次进入界面自动恢复
  Future<void> _saveInterval() async {
    if (gongkeitem == null) return;
    await saveDoubleValue(_intervalKey, interval);
  }

  MuyuRhythmPattern get _currentPattern =>
      muyuRhythmStore.patternFor(_selectedPatternId);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['gongkeitem'] is GongKeItemData) {
        gongkeitem = args['gongkeitem'] as GongKeItemData;
        isLoaded = true;
        _selectedPatternId = muyuRhythmStore.selectedPatternId(
          gongKeType: gongkeitem!.gongketype,
          gongKeName: gongkeitem!.name,
        );
        _loadInterval();
      }
    }
  }

  bool get _isRunning => _session.isActive;

  bool get _canResume {
    final total = gongkeitem?.cnt ?? 0;
    return !_isRunning &&
        _session.remainingCount > 0 &&
        _session.remainingCount < total;
  }

  String get _primaryLabel {
    if (_isRunning) return '暂停';
    if (_canResume) return '继续';
    return '开始';
  }

  void _onPrimary() {
    if (_isRunning) {
      _pause();
    } else if (_canResume) {
      _resume();
    } else {
      _start();
    }
  }

  Future<void> _start() async {
    if (gongkeitem == null) return;
    WakelockTools.enable();
    await _session.start(
      pattern: _currentPattern,
      totalCount: gongkeitem!.cnt,
      interval: Duration(milliseconds: (interval * 1000).toInt()),
    );
    _startUiTicker();
    setState(() {});
  }

  Future<void> _resume() async {
    if (gongkeitem == null) return;
    WakelockTools.enable();
    await _session.resume(
      pattern: _currentPattern,
      interval: Duration(milliseconds: (interval * 1000).toInt()),
    );
    _startUiTicker();
    setState(() {});
  }

  void _pause() {
    _session.pause();
    _uiTimer?.cancel();
    WakelockTools.disable();
    setState(() {});
  }

  void _startUiTicker() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
      if (!_session.isActive) {
        _uiTimer?.cancel();
        _uiTimer = null;
      }
    });
  }

  Future<void> _onModeChanged(String? id) async {
    if (id == null || gongkeitem == null) return;
    if (_session.isActive) _pause();
    setState(() => _selectedPatternId = id);
    await muyuRhythmStore.select(
      patternID: id,
      gongKeType: gongkeitem!.gongketype,
      gongKeName: gongkeitem!.name,
    );
  }

  void _openManagement() {
    Navigator.pushNamed(context, '/GongKe/MuyuRhythmManagement').then((_) {
      if (mounted && gongkeitem != null) {
        setState(() {
          _selectedPatternId = muyuRhythmStore.selectedPatternId(
            gongKeType: gongkeitem!.gongketype,
            gongKeName: gongkeitem!.name,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _session.dispose();
    WakelockTools.disable();
    AudioTools.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gongkeitem == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text("加载中...")),
      );
    }

    final total = gongkeitem!.cnt;
    final current = _session.playedCount;
    final patterns = muyuRhythmStore.selectablePatterns;
    final design = RcmTheme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('电子木鱼'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            design.spacing.md,
            design.spacing.xs,
            design.spacing.md,
            design.spacing.xl,
          ),
          children: [
            _buildTaskSummary(),
            SizedBox(height: design.spacing.md),
            _buildPatternCard(patterns),
            SizedBox(height: design.spacing.md),
            _buildIntervalCard(),
            SizedBox(height: design.spacing.md),
            _buildMuyuCard(total: total, current: current),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummary() {
    final design = RcmTheme.of(context);
    final presentation = GongKeTypePresentation.of(gongkeitem!.gongketype);
    return Container(
      padding: EdgeInsets.all(design.spacing.md),
      decoration: BoxDecoration(
        color: design.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.borderOf(context)),
        boxShadow: [RcmShadowTokens.subtle.boxShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: design.colors.accentSoft,
              borderRadius: BorderRadius.circular(design.radius.md),
            ),
            child:
                Icon(presentation.icon, color: design.colors.primary, size: 25),
          ),
          SizedBox(width: design.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gongkeitem!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: design.typography.body15Strong.copyWith(
                      color: design.textPrimaryOf(context),
                    )),
                const SizedBox(height: 4),
                Text('目标 ${gongkeitem!.cnt} ${presentation.unit}',
                    style: design.typography.caption.copyWith(
                      color: design.textSecondaryOf(context),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuyuCard({required int total, required int current}) {
    final design = RcmTheme.of(context);
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final completed = total > 0 && current >= total;
    final statusColor =
        completed ? design.colors.success : design.colors.primary;
    final stateLabel = completed
        ? '今日目标已完成'
        : _isRunning
            ? '木鱼敲击中'
            : _canResume
                ? '已暂停'
                : '准备开始';

    return Container(
      padding: EdgeInsets.all(design.spacing.lg),
      decoration: BoxDecoration(
        color: design.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(design.radius.xl),
        border: Border.all(color: statusColor.withOpacity(0.18)),
        boxShadow: [design.shadow.boxShadow],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: statusColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$current',
                      style: TextStyle(
                        fontSize: 54,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      stateLabel,
                      style: design.typography.bodyStrong.copyWith(
                        color: design.textSecondaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '共 $total 声',
                      style: design.typography.caption.copyWith(
                        color: design.textTertiaryOf(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: design.spacing.lg),
          SizedBox(
            width: double.infinity,
            child: RcmButton(
              icon: _isRunning
                  ? Icons.pause_rounded
                  : _canResume
                      ? Icons.play_arrow_rounded
                      : Icons.notifications_active_outlined,
              text: _primaryLabel,
              onPressed: _onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(List<MuyuRhythmPattern> patterns) {
    final design = RcmTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: design.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.borderOf(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(design.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq_rounded,
                        color: design.colors.primary, size: 22),
                    SizedBox(width: design.spacing.xs),
                    Text('播放模式', style: design.typography.body15Strong),
                  ],
                ),
                SizedBox(height: design.spacing.sm),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedPatternId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  disabledHint: Text(_currentPattern.displayName),
                  items: patterns
                      .map((pattern) => DropdownMenuItem(
                            value: pattern.id,
                            child: Text(pattern.displayName),
                          ))
                      .toList(),
                  onChanged: _isRunning ? null : _onModeChanged,
                ),
                const SizedBox(height: 6),
                Text(
                  _currentPattern.groupedDescription,
                  style: design.typography.caption.copyWith(
                    color: design.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: design.borderOf(context)),
          ListTile(
            leading: Icon(Icons.tune_rounded, color: design.colors.primary),
            title: const Text('管理十念法'),
            subtitle: const Text('编辑内置节奏或创建自己的敲击方式'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isRunning ? null : _openManagement,
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalCard() {
    final design = RcmTheme.of(context);
    return Container(
      padding: EdgeInsets.all(design.spacing.md),
      decoration: BoxDecoration(
        color: design.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.borderOf(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded, color: design.colors.primary, size: 22),
              SizedBox(width: design.spacing.xs),
              Expanded(
                child: Text('敲击间隔', style: design.typography.body15Strong),
              ),
              RcmBadge('${interval.toStringAsFixed(1)} 秒'),
            ],
          ),
          SizedBox(height: design.spacing.sm),
          Slider(
            min: 0.5,
            max: 3.0,
            value: interval,
            divisions: 25,
            label: '${interval.toStringAsFixed(1)} 秒',
            onChanged:
                _isRunning ? null : (value) => setState(() => interval = value),
            onChangeEnd: _isRunning ? null : (_) => _saveInterval(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: design.spacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('较快 · 0.5秒', style: design.typography.caption),
                Text('3.0秒 · 较慢', style: design.typography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
