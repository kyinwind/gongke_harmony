import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../database.dart';
import '../model/tip_file.dart';

class TipExportService {
  const TipExportService({this.codec = const TipFileCodec()});

  final TipFileCodec codec;

  Future<File> createTemporaryJson(AppDatabase db, int bookId) async {
    final book = await (db.select(db.tipBook)
          ..where((table) => table.id.equals(bookId)))
        .getSingle();
    final json = await exportBook(db, bookId);
    final directory = await getTemporaryDirectory();
    final safeName = book.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final file = File(path.join(
        directory.path, '${safeName.isEmpty ? '开示录' : safeName}.json'));
    await file.writeAsBytes(utf8.encode(json), flush: true);
    return file;
  }

  Future<bool> saveBook(AppDatabase db, int bookId) async {
    final file = await createTemporaryJson(db, bookId);
    try {
      final saved = await FilePicker.platform.saveFile(
        fileName: path.basename(file.path),
        initialDirectory: file.path,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      return saved != null;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  Future<String> exportBook(AppDatabase db, int bookId) async {
    final book = await (db.select(db.tipBook)
          ..where((table) => table.id.equals(bookId)))
        .getSingleOrNull();
    if (book == null) {
      throw StateError('找不到要导出的开示录');
    }
    final records = await (db.select(db.tipRecord)
          ..where((table) => table.bookId.equals(bookId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sortOrder),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    final file = TipBookFileDto(
      quotation: TipBookDto(
        id: book.sourceId ?? 'harmony-book-${book.id}',
        name: book.name,
        remarks: book.remarks ?? '',
        image: book.image,
        version: book.version ?? '1',
        productId: book.productId,
        records: records
            .map(
              (record) => TipRecordDto(
                id: record.jsonId ?? record.id.toString(),
                content: record.content,
                isFavorite: record.favoriteDateTime != null,
                completedDate: record.completedDateTime,
                comments: record.comments,
                tag: record.tag,
              ),
            )
            .toList(),
      ),
    );
    return codec.encode(file);
  }
}
