import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';

enum TodayTipMode { sequential, random }

class TodayTipSelection {
  const TodayTipSelection({required this.book, required this.record});

  final TipBookData book;
  final TipRecordData record;
}

class TodayTipSettings {
  static const _modeKey = 'gongke.todayTip.mode';
  static const _startDateKey = 'gongke.todayTip.startDate';

  static Future<TodayTipMode> loadMode() async {
    final value = (await SharedPreferences.getInstance()).getString(_modeKey);
    return value == TodayTipMode.random.name
        ? TodayTipMode.random
        : TodayTipMode.sequential;
  }

  static Future<void> saveMode(TodayTipMode mode) async {
    await (await SharedPreferences.getInstance())
        .setString(_modeKey, mode.name);
  }

  static Future<DateTime> loadStartDate({DateTime? fallback}) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = DateTime.tryParse(prefs.getString(_startDateKey) ?? '');
    if (stored != null) return DateTime(stored.year, stored.month, stored.day);
    final value = fallback ?? DateTime.now();
    final date = DateTime(value.year, value.month, value.day);
    await prefs.setString(_startDateKey, date.toIso8601String());
    return date;
  }
}

class TodayTipService {
  const TodayTipService(this.db);

  final AppDatabase db;

  Future<TodayTipSelection?> select({
    required DateTime now,
    required DateTime startDate,
    required TodayTipMode mode,
    String seedScope = 'app',
  }) async {
    final books = await (db.select(db.tipBook)
          ..orderBy([
            (table) => OrderingTerm.desc(table.favoriteDateTime),
            (table) => OrderingTerm.desc(table.createDateTime),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    final candidates = <TodayTipSelection>[];
    for (final book in books) {
      final records = await (db.select(db.tipRecord)
            ..where((table) => table.bookId.equals(book.id))
            ..orderBy([
              (table) => OrderingTerm.asc(table.sortOrder),
              (table) => OrderingTerm.asc(table.id),
            ]))
          .get();
      candidates.addAll(
        records.map((record) => TodayTipSelection(book: book, record: record)),
      );
    }
    if (candidates.isEmpty) return null;

    final localDay = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(startDate.year, startDate.month, startDate.day);
    final index = selectIndex(
      length: candidates.length,
      now: localDay,
      startDate: firstDay,
      mode: mode,
      seedScope: seedScope,
    );
    return candidates[index];
  }

  static int selectIndex({
    required int length,
    required DateTime now,
    required DateTime startDate,
    required TodayTipMode mode,
    String seedScope = 'app',
  }) {
    if (length <= 0) throw ArgumentError.value(length, 'length', '必须大于 0');
    final localDay = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(startDate.year, startDate.month, startDate.day);
    return mode == TodayTipMode.sequential
        ? _positiveModulo(localDay.difference(firstDay).inDays, length)
        : _positiveModulo(
            _stableHash('${localDay.toIso8601String()}|$seedScope'),
            length,
          );
  }

  static int _positiveModulo(int value, int divisor) =>
      (value % divisor + divisor) % divisor;

  static int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
