import 'package:flutter/foundation.dart';

import '../main.dart';
import 'platform_tools.dart';
import 'widget_snapshot_service.dart';

Future<void> syncTaskAndCalendarCards() async {
  if (!PlatformUtils.isHarmonyOS) return;
  try {
    await WidgetSnapshotService(globalDB).syncCards(
      const {'TodayTasksCard', 'GongKeCalendarCard'},
    );
  } catch (error) {
    debugPrint('同步功课卡片失败：$error');
  }
}
