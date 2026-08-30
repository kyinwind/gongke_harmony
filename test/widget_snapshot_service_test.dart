import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/widget_snapshot_service.dart';
import 'package:gongke/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('empty snapshots keep stable schema and explicit empty tip state',
      () async {
    final snapshots = await WidgetSnapshotService(db).buildAll(
      now: DateTime(2026, 8, 15, 12),
    );
    final tasks =
        jsonDecode(snapshots['TodayTasksCard']!) as Map<String, dynamic>;
    final tip = jsonDecode(snapshots['TodayTipCard']!) as Map<String, dynamic>;
    final tipCatalog =
        jsonDecode(snapshots['TodayTipCatalog']!) as Map<String, dynamic>;
    final calendar =
        jsonDecode(snapshots['GongKeCalendarCard']!) as Map<String, dynamic>;

    expect(tasks['schemaVersion'], 1);
    expect(tasks['items'], isEmpty);
    expect(tasks['updatedText'], '更新：8月15日 12:00');
    expect(tasks['todayDay'], 15);
    expect(tasks['monthLabel'], '8月');
    expect(tasks['weekdayLabel'], '周六');
    expect(tip['empty'], isTrue);
    expect(tip['updatedText'], '更新：8月15日 12:00');
    expect(tip['todayDay'], 15);
    expect(tip['monthLabel'], '8月');
    expect(tip['weekdayLabel'], '周六');
    expect(tip['content'], isEmpty);
    expect(tip['bookName'], isEmpty);
    expect(tip['imageUri'], isEmpty);
    expect(tip['bookId'], 0);
    expect(tip['recordId'], 0);
    expect(tip['mode'], 'sequential');
    expect(tipCatalog['mode'], 'sequential');
    expect(tipCatalog['books'], isEmpty);
    expect(calendar['cells'], hasLength(42));
    expect(calendar['todayDay'], 15);
    expect(calendar['monthLabel'], '8月');
    expect(calendar['weekdayLabel'], '周六');
    expect(calendar['updatedText'], '更新：8月15日 12:00');
    final todayCells = (calendar['cells'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((cell) => cell['isToday'] == true)
        .toList();
    expect(todayCells, hasLength(1));
    expect(todayCells.single['date'], '2026-08-15');
  });

  test('snapshot contains stable tip ids and task completion', () async {
    final bookId = await db.into(db.tipBook).insert(
          TipBookCompanion.insert(name: '测试开示', image: ''),
        );
    await db.into(db.tipRecord).insert(
          TipRecordCompanion.insert(bookId: bookId, content: '开示正文'),
        );
    await db.into(db.gongKeItem).insert(
          GongKeItemCompanion.insert(
            name: '念佛',
            fayuanId: 1,
            gongketype: '念佛',
            gongKeDay: '2026-08-15',
            cnt: const Value(1),
            isComplete: const Value(true),
          ),
        );

    final snapshots = await WidgetSnapshotService(db).buildAll(
      now: DateTime(2026, 8, 15, 12),
    );
    final tasks =
        jsonDecode(snapshots['TodayTasksCard']!) as Map<String, dynamic>;
    final tip = jsonDecode(snapshots['TodayTipCard']!) as Map<String, dynamic>;
    final tipCatalog =
        jsonDecode(snapshots['TodayTipCatalog']!) as Map<String, dynamic>;
    final calendar =
        jsonDecode(snapshots['GongKeCalendarCard']!) as Map<String, dynamic>;

    expect((tasks['items'] as List).single['name'], '念佛');
    expect(tasks['completed'], isTrue);
    expect((tasks['items'] as List).single['isComplete'], isTrue);
    expect((tasks['items'] as List).single['currentCount'], 1);
    expect((tasks['items'] as List).single['count'], 1);
    expect(tip['bookId'], bookId);
    expect(tip['recordId'], isA<int>());
    expect(tip['content'], '开示正文');
    expect((tipCatalog['books'] as List), hasLength(1));
    expect(((tipCatalog['books'] as List).single['records'] as List),
        hasLength(1));
    expect(
        ((tipCatalog['books'] as List).single['records'] as List)
            .single['content'],
        '开示正文');
    final todayCell = (calendar['cells'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .singleWhere((cell) => cell['date'] == '2026-08-15');
    expect(todayCell['completionPercent'], 100);
    expect(todayCell['completionLabel'], '100%');
  });

  test('calendar masks outside-month cells and exposes current-month states',
      () async {
    Future<void> addTask(String day, String name, bool complete) async {
      await db.into(db.gongKeItem).insert(
            GongKeItemCompanion.insert(
              name: name,
              fayuanId: 1,
              gongketype: '念佛',
              gongKeDay: day,
              cnt: const Value(1),
              isComplete: Value(complete),
            ),
          );
    }

    // This outside-month task must not leak a status or label into August.
    await addTask('2026-07-27', '上月功课', false);
    await addTask('2026-08-15', '今日未完成', false);
    await addTask('2026-08-16', '未来待办', false);
    await addTask('2026-08-17', '部分完成一', true);
    await addTask('2026-08-17', '部分完成二', false);
    await addTask('2026-08-18', '全部完成', true);

    final snapshots = await WidgetSnapshotService(db).buildAll(
      now: DateTime(2026, 8, 15, 12),
    );
    final calendar =
        jsonDecode(snapshots['GongKeCalendarCard']!) as Map<String, dynamic>;
    final cells =
        (calendar['cells'] as List<dynamic>).cast<Map<String, dynamic>>();

    expect(cells, hasLength(42));
    final outsideCells = cells.where((cell) => cell['inMonth'] == false);
    expect(outsideCells, isNotEmpty);
    for (final cell in outsideCells) {
      expect(cell['plannedCount'], 0);
      expect(cell['completedCount'], 0);
      expect(cell['completionPercent'], null);
      expect(cell['completionLabel'], '');
      expect(cell['status'], 'none');
      expect(cell['isToday'], isFalse);
    }

    Map<String, dynamic> cellFor(String date) =>
        cells.singleWhere((cell) => cell['date'] == date);
    expect(cellFor('2026-08-15')['completionLabel'], '0%');
    expect(cellFor('2026-08-15')['status'], 'pending');
    expect(cellFor('2026-08-16')['completionLabel'], 'todo');
    expect(cellFor('2026-08-16')['status'], 'pending');
    expect(cellFor('2026-08-17')['completionLabel'], '50%');
    expect(cellFor('2026-08-17')['status'], 'pending');
    expect(cellFor('2026-08-18')['completionLabel'], '100%');
    expect(cellFor('2026-08-18')['status'], 'completed');
  });

  test('deleting the final tip emits explicit values that clear card state',
      () async {
    final bookId = await db.into(db.tipBook).insert(
          TipBookCompanion.insert(name: '待删除开示录', image: 'image'),
        );
    await db.into(db.tipRecord).insert(
          TipRecordCompanion.insert(bookId: bookId, content: '即将删除的开示'),
        );
    await (db.delete(db.tipRecord)
          ..where((table) => table.bookId.equals(bookId)))
        .go();
    await (db.delete(db.tipBook)..where((table) => table.id.equals(bookId)))
        .go();

    final snapshots = await WidgetSnapshotService(db).buildAll(
      now: DateTime(2026, 8, 16, 1, 30),
    );
    final tip = jsonDecode(snapshots['TodayTipCard']!) as Map<String, dynamic>;
    final catalog =
        jsonDecode(snapshots['TodayTipCatalog']!) as Map<String, dynamic>;

    expect(tip['empty'], isTrue);
    expect(tip['content'], '');
    expect(tip['bookName'], '');
    expect(tip['imageUri'], '');
    expect(tip['bookId'], 0);
    expect(tip['recordId'], 0);
    expect(catalog['books'], isEmpty);
  });
}
