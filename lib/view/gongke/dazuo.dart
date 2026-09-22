import 'package:flutter/material.dart';
import 'dart:async';
import '../../database.dart';
import '../../main.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_design_system/easy_design_system.dart';
import '../../comm/audio_tools.dart';
import '../../comm/wakelock_tools.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';

class DaZuoPage extends StatefulWidget {
  const DaZuoPage({super.key});

  @override
  State<DaZuoPage> createState() => _DaZuoPageState();
}

class _DaZuoPageState extends State<DaZuoPage> {
  GongKeItemData? gki; //根据传入的参数获取功课项
  bool isLoaded = false;//是否已经载入数据，如果已经载入就不需要重复载入
  bool isGoingon = false;
  int totalMinutes = 0;
  int loopIndex = 0;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['gongkeitem'] is GongKeItemData) {
        gki = args['gongkeitem'] as GongKeItemData;
        totalMinutes = gki!.cnt.clamp(10, 600);
        loopIndex = totalMinutes * 60;
        isLoaded = true;
      }
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void startTimer(GongKeItemData gki) {
    loopIndex = totalMinutes * 60;
    if (loopIndex == 0) loopIndex = gki.cnt * 60;

    playYinqingSequence(() {
      setState(() => isGoingon = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isGoingon) {
          timer.cancel();
          return;
        }
        setState(() {
          if (loopIndex > 0) {
            loopIndex--;
            WakelockTools.enable();
          } else {
            isGoingon = false;
            makeComplete(gki);
            playYinqingSequence(() {});
            timer.cancel();
            WakelockTools.disable();
          }
        });
      });
    });
  }

  Future<void> makeComplete(GongKeItemData gki) async {
    await globalDB.managers.gongKeItem
        .filter((item) => item.id.equals(gki.id))
        .update((o) => o(isComplete: const Value(true)));
    await syncTaskAndCalendarCards();
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() => isGoingon = false);
  }

  void playYinqingSequence(VoidCallback onFinished) {
    int count = 0;

    void playNext() {
      if (count < 3) {
        AudioTools.playLocalAsset('mp3/yinqing.wav', onComplete: playNext);
        count++;
      } else {
        onFinished();
      }
    }

    playNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioTools.stop();
    WakelockTools.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || gki == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final tokens = context.edsTokens; final scheme = context.edsScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('打坐计时'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.md,
            tokens.spacing.xs,
            tokens.spacing.md,
            tokens.spacing.xl,
          ),
          children: [
            _buildTaskSummary(),
            SizedBox(height: tokens.spacing.md),
            _buildTimerCard(),
            SizedBox(height: tokens.spacing.md),
            _buildDurationCard(),
            SizedBox(height: tokens.spacing.md),
            _buildHintCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummary() {
    final tokens = context.edsTokens; final scheme = context.edsScheme;
    final presentation = GongKeTypePresentation.of(gki!.gongketype);
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: scheme.border),
        boxShadow: [BoxShadow(color: tokens.colors.primary.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.colors.primarySoft,
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child:
                Icon(presentation.icon, size: 26, color: tokens.colors.primary),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gki!.name,
                    style: tokens.typography.body15Strong.copyWith(
                      color: scheme.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text('每日目标 ${gki!.cnt} ${presentation.unit}',
                    style: tokens.typography.caption.copyWith(
                      color: scheme.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final tokens = context.edsTokens; final scheme = context.edsScheme;
    final totalSeconds = totalMinutes * 60;
    final elapsed = totalSeconds <= 0
        ? 0.0
        : ((totalSeconds - loopIndex) / totalSeconds).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.colors.primary.withValues(alpha: 0.16)),
        boxShadow: [BoxShadow(color: tokens.colors.primary.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 10))],
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
                    value: isGoingon ? elapsed : 0,
                    strokeWidth: 10,
                    backgroundColor: tokens.colors.primary.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(tokens.colors.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(loopIndex),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: scheme.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isGoingon ? '正在入静' : '准备开始',
                      style: tokens.typography.body.copyWith(
                        color: isGoingon
                            ? tokens.colors.primary
                            : scheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          SizedBox(
            width: double.infinity,
            child: EdsButton(
              isGoingon ? '结束本次打坐' : '开始打坐',
              role: isGoingon ? EdsButtonRole.danger : EdsButtonRole.primary,
              systemImage: isGoingon ? Icons.stop_rounded : Icons.play_arrow_rounded,
              action: isGoingon ? stopTimer : () => startTimer(gki!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard() {
    final tokens = context.edsTokens; final scheme = context.edsScheme;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: scheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  color: tokens.colors.primary, size: 22),
              SizedBox(width: tokens.spacing.xs),
              Text('打坐时长', style: tokens.typography.body15Strong),
              const Spacer(),
              EdsBadge('$totalMinutes 分钟'),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          DaZuoTimeView(
            initialMinutes: totalMinutes,
            onChanged: (val) {
              setState(() {
                totalMinutes = val;
                loopIndex = val * 60;
              });
            },
            isDisabled: isGoingon,
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    final tokens = context.edsTokens; final scheme = context.edsScheme;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.colors.primarySoft,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_outlined,
              color: tokens.colors.primary, size: 20),
          SizedBox(width: tokens.spacing.xs),
          Expanded(
            child: Text(
              '开始与结束时各敲三声引磬。计时期间屏幕将保持点亮。',
              style: tokens.typography.caption.copyWith(
                color: scheme.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DaZuoTimeView extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;
  final bool isDisabled;

  const DaZuoTimeView({
    super.key,
    required this.initialMinutes,
    required this.onChanged,
    required this.isDisabled,
  });

  @override
  State<DaZuoTimeView> createState() => _DaZuoTimeViewState();
}

class _DaZuoTimeViewState extends State<DaZuoTimeView> {
  static const double _minimumMinutes = 10;
  static const double _maximumMinutes = 600;
  double _gongkeDaZuoTime = 60;

  @override
  void initState() {
    super.initState();
    _gongkeDaZuoTime = widget.initialMinutes
        .toDouble()
        .clamp(_minimumMinutes, _maximumMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _gongkeDaZuoTime,
          min: _minimumMinutes,
          max: _maximumMinutes,
          divisions: 59,
          label: _gongkeDaZuoTime.toStringAsFixed(0),
          onChanged: widget.isDisabled
              ? null
              : (val) {
                  setState(() => _gongkeDaZuoTime = val);
                  widget.onChanged(val.toInt());
                },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('10 分钟'), Text('600 分钟')],
          ),
        ),
      ],
    );
  }
}
