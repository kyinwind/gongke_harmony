import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../comm/audio_tools.dart';
import '../../comm/pub_tools.dart';
import '../../comm/wakelock_tools.dart';
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
      if (mounted) setState(() {});
    });
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

    return Scaffold(
      appBar: AppBar(title: const Text("电子木鱼"), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("功课内容", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("${gongkeitem!.name} ${gongkeitem!.cnt}遍"),
            ),
            const SizedBox(height: 12),
            const Text("播放模式", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedPatternId,
              disabledHint: Text(_currentPattern.displayName),
              items: patterns
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.displayName),
                      ))
                  .toList(),
              onChanged: _isRunning ? null : _onModeChanged,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _currentPattern.groupedDescription,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune, color: Colors.blue),
              title: const Text('管理十念法'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openManagement,
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text(
                  "请设置电子木鱼时间间隔：",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
              ],
            ),
            Row(
              children: [
                Text(
                  interval.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                const Text("单位:秒"),
              ],
            ),
            Row(
              children: [
                const Text('0.5秒'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    min: 0.5,
                    max: 3.0,
                    value: interval,
                    divisions: 45,
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              interval = value;
                            });
                          },
                    onChangeEnd: _isRunning
                        ? null
                        : (value) {
                            _saveInterval();
                          },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('3秒'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "点击按钮开始敲打木鱼：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _onPrimary,
                        style: AppButtonStyle.primaryButton,
                        child: Text(_primaryLabel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("总共 $total 声，当前第 $current 声"),
                  LinearProgressIndicator(
                    value: total > 0 ? current / total : 0,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
