import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';

import '../database.dart';
import 'today_tip_service.dart';
import 'widget_image_service.dart';

class WidgetSnapshotService {
  WidgetSnapshotService(this.db, {MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('gongke/widgets');

  final AppDatabase db;
  final MethodChannel _channel;

  Future<void> syncAll({DateTime? now}) async {
    await syncCards(
      const {'TodayTasksCard', 'TodayTipCard', 'GongKeCalendarCard'},
      now: now,
    );
  }

  Future<void> syncCards(Set<String> cardNames, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    final snapshots = <String, String>{};
    if (cardNames.contains('TodayTasksCard')) {
      snapshots['TodayTasksCard'] = jsonEncode(await _buildTodayTasks(current));
    }
    if (cardNames.contains('TodayTipCard')) {
      snapshots['TodayTipCard'] = jsonEncode(await _buildTodayTip(current));
    }
    if (cardNames.contains('GongKeCalendarCard')) {
      snapshots['GongKeCalendarCard'] =
          jsonEncode(await _buildCalendar(current));
    }
    snapshots['cardNames'] = jsonEncode(cardNames.toList());
    await _channel.invokeMethod<void>('writeSnapshots', snapshots);
  }

  Future<Map<String, String>> buildAll({required DateTime now}) async {
    return {
      'TodayTasksCard': jsonEncode(await _buildTodayTasks(now)),
      'TodayTipCard': jsonEncode(await _buildTodayTip(now)),
      'GongKeCalendarCard': jsonEncode(await _buildCalendar(now)),
    };
  }

  Future<Map<String, Object?>> _buildTodayTasks(DateTime now) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final items = await (db.select(db.gongKeItem)
          ..where((table) => table.gongKeDay.equals(dateKey))
          ..orderBy([(table) => OrderingTerm.asc(table.idx)]))
        .get();
    return {
      'schemaVersion': 1,
      'generatedAt': now.toIso8601String(),
      'date': dateKey,
      'updatedText': '更新：${DateFormat('M月d日 HH:mm').format(now)}',
      'todayDay': now.day,
      'monthLabel': DateFormat('M月').format(now),
      'weekdayLabel': const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1],
      'completed': items.isNotEmpty && items.every((item) => item.isComplete),
      'hasMore': items.length > 5,
      'items': items
          .take(5)
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'count': item.cnt,
                'currentCount': item.curCnt,
                'isComplete': item.isComplete,
              })
          .toList(),
    };
  }

  Future<Map<String, Object?>> _buildTodayTip(DateTime now) async {
    final mode = await TodayTipSettings.loadMode();
    final startDate = await TodayTipSettings.loadStartDate(fallback: now);
    final selected = await TodayTipService(db).select(
      now: now,
      startDate: startDate,
      mode: mode,
      seedScope: 'TodayTipCard',
    );
    if (selected == null) {
      return {
        'schemaVersion': 1,
        'generatedAt': now.toIso8601String(),
        'date': DateFormat('yyyy-MM-dd').format(now),
        'updatedText': '更新：${DateFormat('M月d日 HH:mm').format(now)}',
        'todayDay': now.day,
        'monthLabel': DateFormat('M月').format(now),
        'weekdayLabel': const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1],
        'empty': true,
      };
    }
    final imagePath =
        await const WidgetImageService().cacheThumbnail(selected.book.image);
    return {
      'schemaVersion': 1,
      'generatedAt': now.toIso8601String(),
      'date': DateFormat('yyyy-MM-dd').format(now),
      'updatedText': '更新：${DateFormat('M月d日 HH:mm').format(now)}',
      'todayDay': now.day,
      'monthLabel': DateFormat('M月').format(now),
      'weekdayLabel': const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1],
      'empty': false,
      'bookId': selected.book.id,
      'recordId': selected.record.id,
      'bookName': selected.book.name,
      'content': selected.record.content,
      'imagePath': imagePath,
      'comments': selected.record.comments,
      'mode': mode.name,
      'bookSourceId': selected.book.sourceId,
      'recordJsonId': selected.record.jsonId,
    };
  }

  Future<Map<String, Object?>> _buildCalendar(DateTime now) async {
    final currentMonth = DateTime(now.year, now.month);
    final rangeStart = DateTime(currentMonth.year, currentMonth.month - 1);
    final rangeEndExclusive =
        DateTime(currentMonth.year, currentMonth.month + 2);
    final formatter = DateFormat('yyyy-MM-dd');
    final items = await (db.select(db.gongKeItem)
          ..where((table) => table.gongKeDay.isBiggerOrEqualValue(
                formatter.format(rangeStart),
              ))
          ..where((table) => table.gongKeDay.isSmallerThanValue(
                formatter.format(rangeEndExclusive),
              )))
        .get();
    final counts = <String, Map<String, int>>{};
    for (final item in items) {
      final day = counts.putIfAbsent(
        item.gongKeDay,
        () => {'plannedCount': 0, 'completedCount': 0},
      );
      day['plannedCount'] = day['plannedCount']! + 1;
      if (item.isComplete) {
        day['completedCount'] = day['completedCount']! + 1;
      }
    }
    final gridStart = currentMonth.subtract(
      Duration(days: currentMonth.weekday - DateTime.monday),
    );
    final cells = List.generate(42, (index) {
      final date = gridStart.add(Duration(days: index));
      final key = formatter.format(date);
      final count = counts[key];
      final planned = count?['plannedCount'] ?? 0;
      final completed = count?['completedCount'] ?? 0;
      final completionPercent = planned == 0
          ? null
          : ((completed * 100) / planned).round().clamp(0, 100);
      final isFuture = DateTime(date.year, date.month, date.day)
          .isAfter(DateTime(now.year, now.month, now.day));
      return {
        'date': key,
        'day': date.day,
        'lunar': Lunar.fromDate(date).getDayInChinese(),
        'inMonth': date.month == currentMonth.month,
        'isToday': key == formatter.format(now),
        'isWeekend': date.weekday >= DateTime.saturday,
        'plannedCount': planned,
        'completedCount': completed,
        'completionPercent': completionPercent,
        'completionLabel': planned == 0
            ? ''
            : (isFuture && completed == 0 ? 'todo' : '$completionPercent%'),
        'status': planned == 0
            ? 'none'
            : (completed >= planned ? 'completed' : 'pending'),
      };
    });
    return {
      'schemaVersion': 1,
      'generatedAt': now.toIso8601String(),
      'timeZone': now.timeZoneName,
      'rangeStart': formatter.format(rangeStart),
      'rangeEnd': formatter.format(
        rangeEndExclusive.subtract(const Duration(days: 1)),
      ),
      'days': counts,
      'monthTitle': DateFormat('yyyy年M月').format(currentMonth),
      'todayDay': now.day,
      'monthLabel': DateFormat('M月').format(now),
      'weekdayLabel': const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1],
      'updatedText': '更新：${DateFormat('M月d日 HH:mm').format(now)}',
      'cells': cells,
    };
  }
}
