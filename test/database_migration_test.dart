import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('schema v1 tip data upgrades to v2 without data loss', () async {
    final directory =
        await Directory.systemTemp.createTemp('gongke_migration_');
    final file = File('${directory.path}/app.db');
    final legacy = sqlite.sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE tip_book (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        create_date_time INTEGER NOT NULL,
        favorite_date_time INTEGER NULL,
        remarks TEXT NULL, bk1 TEXT NULL, bk2 TEXT NULL,
        name TEXT NOT NULL, image TEXT NOT NULL
      );
      CREATE TABLE tip_record (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        create_date_time INTEGER NOT NULL,
        remarks TEXT NULL, bk1 TEXT NULL, bk2 TEXT NULL,
        content TEXT NOT NULL, book_id INTEGER NOT NULL
      );
      INSERT INTO tip_book
        (create_date_time, name, image) VALUES (1723680000, '旧开示录', '');
      INSERT INTO tip_record
        (create_date_time, content, book_id) VALUES (1723680000, '旧开示正文', 1);
      PRAGMA user_version = 1;
    ''');
    legacy.dispose();

    final db = AppDatabase(NativeDatabase(file));
    try {
      final books = await db.select(db.tipBook).get();
      final records = await db.select(db.tipRecord).get();
      expect(books.single.name, '旧开示录');
      expect(books.single.sourceType, 'userCreated');
      expect(records.single.content, '旧开示正文');
      expect(records.single.comments, '');
      expect(records.single.sortOrder, 0);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
