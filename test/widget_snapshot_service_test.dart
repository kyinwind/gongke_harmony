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
