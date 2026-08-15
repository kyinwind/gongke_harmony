import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'model/tables.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [
    FaYuan,
    GongKeItemsOneDay,
    GongKeItem,
    JingShu,
    TipBook,
    TipRecord,
    BaiChan,
  ],
)
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(tipBook, tipBook.sourceId);
            await m.addColumn(tipBook, tipBook.version);
            await m.addColumn(tipBook, tipBook.sourceType);
            await m.addColumn(tipBook, tipBook.productId);
            // SQLite 不允许 ALTER TABLE ADD COLUMN 使用 CURRENT_TIMESTAMP
            // 这类非常量默认值。先以常量加列，再用原创建时间回填。
            await customStatement(
              'ALTER TABLE tip_book ADD COLUMN updated_date_time INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement(
              'UPDATE tip_book SET updated_date_time = create_date_time WHERE updated_date_time = 0',
            );
            await m.addColumn(tipRecord, tipRecord.jsonId);
            await m.addColumn(tipRecord, tipRecord.favoriteDateTime);
            await m.addColumn(tipRecord, tipRecord.completedDateTime);
            await m.addColumn(tipRecord, tipRecord.comments);
            await m.addColumn(tipRecord, tipRecord.tag);
            await m.addColumn(tipRecord, tipRecord.sortOrder);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return SqfliteQueryExecutor.inDatabaseFolder(
      path: 'app.db',
    );
  }
}
