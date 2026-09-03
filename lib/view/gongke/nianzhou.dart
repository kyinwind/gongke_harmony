import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
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
    final design = RcmTheme.of(context);
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
            design.spacing.md,
            design.spacing.xs,
            design.spacing.md,
            design.spacing.xl,
          ),
          child: Column(
            children: [
              _buildTaskSummary(),
              SizedBox(height: design.spacing.md),
              _buildCounterSection(),
              SizedBox(height: design.spacing.md),
              _buildSwitchSection(),
              SizedBox(height: design.spacing.md),
              _buildHintCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSummary() {
    final design = RcmTheme.of(context);
    final presentation = GongKeTypePresentation.of(gongkeitem.gongketype);
    return Container(
      width: double.infinity,
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
            child: Icon(
              presentation.icon,
              color: design.colors.primary,
              size: 25,
            ),
          ),
          SizedBox(width: design.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gongkeitem.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: design.typography.body15Strong.copyWith(
                    color: design.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '目标 ${gongkeitem.cnt} ${presentation.unit}',
                  style: design.typography.caption.copyWith(
                    color: design.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          if (count >= gongkeitem.cnt)
            const RcmBadge('已完成', style: RcmBadgeStyle.success),
        ],
      ),
    );
  }

  Widget _buildSwitchSection() {
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
          _buildSettingRow(
            icon: Icons.screen_rotation_alt_outlined,
            title: '摇晃计数',
            subtitle: '摇晃手机时自动增加一次',
            value: shakeEnabled,
            onChanged: (val) => setState(() => shakeEnabled = val),
          ),
          Divider(height: 1, indent: 64, color: design.borderOf(context)),
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
    final design = RcmTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: design.spacing.md,
        vertical: design.spacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: design.colors.primary, size: 24),
          SizedBox(width: design.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: design.typography.body15Strong),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: design.typography.caption.copyWith(
                    color: design.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: design.colors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    final design = RcmTheme.of(context);
    final target = gongkeitem.cnt;
    final progress = target <= 0 ? 0.0 : (count / target).clamp(0.0, 1.0);
    final complete = count >= target;
    final statusColor =
        complete ? design.colors.success : design.colors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(design.spacing.lg),
      decoration: BoxDecoration(
        color: design.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(design.radius.xl),
        border: Border.all(color: statusColor.withOpacity(0.18)),
        boxShadow: [design.shadow.boxShadow],
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
            style: design.typography.body15.copyWith(
              color: complete
                  ? design.colors.success
                  : design.textSecondaryOf(context),
            ),
          ),
          SizedBox(height: design.spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: statusColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: design.spacing.lg),
          Material(
            color: statusColor,
            borderRadius: BorderRadius.circular(design.radius.lg),
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
          SizedBox(height: design.spacing.sm),
          TextButton.icon(
            onPressed: count > 0 ? _decrementCount : null,
            icon: const Icon(Icons.undo_rounded, size: 20),
            label: const Text('撤销上一次计数'),
            style: TextButton.styleFrom(
              foregroundColor: design.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    final design = RcmTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(design.spacing.sm),
      decoration: BoxDecoration(
        color: design.colors.accentSoft,
        borderRadius: BorderRadius.circular(design.radius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 20, color: design.colors.primary),
          SizedBox(width: design.spacing.xs),
          Expanded(
            child: Text(
              '开启摇晃计数后，在屏幕点亮时摇晃手机即可计数。',
              style: design.typography.caption.copyWith(
                color: design.textSecondaryOf(context),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
