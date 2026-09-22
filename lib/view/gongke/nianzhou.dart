import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_design_system/easy_design_system.dart';
import '../../comm/audio_tools.dart';
import '../../comm/platform_tools.dart';
import '../../comm/sensor_tools.dart';
import '../../comm/vibration_tools.dart';
import '../../comm/wakelock_tools.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';

class NianzhouPage extends StatefulWidget {
  const NianzhouPage({Key? key}) : super(key: key);

  @override
  State<NianzhouPage> createState() => _NianzhouPageState();
}

class _NianzhouPageState extends State<NianzhouPage> {
  late GongKeItemData gongkeitem;
  VoidCallback? onUpdated;
  int count = 0;
  bool shakeEnabled = true;
  bool vibrateEnabled = true;
  StreamSubscription? _accelerometerSubscription;
  DateTime lastShakeTime = DateTime.now();

  Future<void> _updateCountBeforeExit() async {
    if (count >= gongkeitem.cnt) {
      await globalDB.managers.gongKeItem
          .filter((f) => f.id.equals(gongkeitem.id))
          .update(
              (f) => f(curCnt: Value(count), isComplete: const Value(true)));
    } else {
      await globalDB.managers.gongKeItem
          .filter((f) => f.id.equals(gongkeitem.id))
          .update(
              (f) => f(curCnt: Value(count), isComplete: const Value(false)));
    }
    await syncTaskAndCalendarCards();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      gongkeitem = args['gongkeitem'] as GongKeItemData;
      onUpdated = args['onUpdated'] as VoidCallback?;

      if (gongkeitem.curCnt > 0) {
        count = gongkeitem.curCnt;
      }
    }

    if (PlatformUtils.supportsShakeSensor) {
      _startListeningShake();
    }
  }

  void _startListeningShake() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = SensorTools.accelerometerEvents().listen((
      AccelerometerReading event,
    ) {
      if (!shakeEnabled) return;

      double delta = event.x.abs() + event.y.abs() + event.z.abs();
      if (delta > 38) {
        final now = DateTime.now();
        if (now.difference(lastShakeTime).inMilliseconds > 2000) {
          lastShakeTime = now;
          _incrementCount();
        }
      }
    });
  }

  void _incrementCount() {
    WakelockTools.enable();
    final previousCount = count;
    setState(() {
      count += 1;
    });
    final reachedTarget =
        previousCount < gongkeitem.cnt && count >= gongkeitem.cnt;

    if (vibrateEnabled) {
      VibrationTools.vibrate();
    }

    // AudioTools 使用单一播放器。达标时若同时触发木鱼和引磬，两次异步
    // stop/play 会相互竞争。达标这一击只播放引磬，普通计数才播放木鱼。
    if (reachedTarget) {
      AudioTools.playLocalAsset('mp3/yinqing.wav');
    } else if (vibrateEnabled) {
      AudioTools.playLocalAsset('mp3/muyu.wav');
    }
  }

  void _decrementCount() {
    setState(() {
      if (count > 0) count -= 1;
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    WakelockTools.disable();
    // 先保存数据
    _updateCountBeforeExit().then((_) {
      // 数据保存完成后，使用 SchedulerBinding 在下一帧回调
      //print('-----------开始onUpdated?.call();');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onUpdated?.call();
        //print('-----------onUpdated?.call()完成');
      });
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('念咒计数'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.md,
            tokens.spacing.xs,
            tokens.spacing.md,
            tokens.spacing.xl,
          ),
          child: Column(
            children: [
              _buildTaskSummary(),
              SizedBox(height: tokens.spacing.md),
              _buildCounterSection(),
              SizedBox(height: tokens.spacing.md),
              _buildSwitchSection(),
              SizedBox(height: tokens.spacing.md),
              _buildHintCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSummary() {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final presentation = GongKeTypePresentation.of(gongkeitem.gongketype);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: scheme.border),
        boxShadow: [
          BoxShadow(
              color: tokens.colors.primary.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
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
            child: Icon(
              presentation.icon,
              color: tokens.colors.primary,
              size: 25,
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gongkeitem.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.typography.body15Strong.copyWith(
                    color: scheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '目标 ${gongkeitem.cnt} ${presentation.unit}',
                  style: tokens.typography.caption.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (count >= gongkeitem.cnt)
            const EdsBadge('已完成', style: EdsBadgeStyle.success),
        ],
      ),
    );
  }

  Widget _buildSwitchSection() {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: scheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.screen_rotation_alt_outlined,
            title: '摇晃计数',
            subtitle: '摇晃手机时自动增加一次',
            value: shakeEnabled,
            onChanged: (val) => setState(() => shakeEnabled = val),
          ),
          Divider(height: 1, indent: 64, color: scheme.border),
          _buildSettingRow(
            icon: Icons.vibration_outlined,
            title: '震动与木鱼声',
            subtitle: '每次计数时提供触感和声音反馈',
            value: vibrateEnabled,
            onChanged: (val) => setState(() => vibrateEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: tokens.colors.primary, size: 24),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tokens.typography.body15Strong),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: tokens.typography.caption.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: tokens.colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final target = gongkeitem.cnt;
    final progress = target <= 0 ? 0.0 : (count / target).clamp(0.0, 1.0);
    final complete = count >= target;
    final statusColor =
        complete ? tokens.colors.success : tokens.colors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: scheme.cardBackground,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
              color: tokens.colors.primary.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complete ? '今日目标已完成' : '目标 $target 遍',
            style: tokens.typography.body15.copyWith(
              color: complete ? tokens.colors.success : scheme.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Material(
            color: statusColor,
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _incrementCount,
              child: SizedBox(
                width: double.infinity,
                height: 112,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/muyu-yellow-32.svg',
                      color: Colors.white,
                      width: 38,
                      height: 38,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '点击计数',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          TextButton.icon(
            onPressed: count > 0 ? _decrementCount : null,
            icon: const Icon(Icons.undo_rounded, size: 20),
            label: const Text('撤销上一次计数'),
            style: TextButton.styleFrom(
              foregroundColor: scheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: tokens.colors.primarySoft,
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 20, color: tokens.colors.primary),
          SizedBox(width: tokens.spacing.xs),
          Expanded(
            child: Text(
              '开启摇晃计数后，在屏幕点亮时摇晃手机即可计数。',
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
