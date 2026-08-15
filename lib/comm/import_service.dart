import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:gongke/comm/file_import_adapter.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:gongke/model/tip_file.dart';

enum TipImportConflictStrategy { skip, overwrite, saveAsNew }

enum ImportItemStatus { imported, skipped, failed }

class TipImportPreview {
  const TipImportPreview(
      {required this.fileName,
      this.bookName,
      this.conflict = false,
      this.error});
  final String fileName;
  final String? bookName;
  final bool conflict;
  final String? error;
}

class ImportItemResult {
  const ImportItemResult(
      {required this.fileName, required this.status, required this.message});
  final String fileName;
  final ImportItemStatus status;
  final String message;
}

class BatchImportResult {
  const BatchImportResult(this.items);
  final List<ImportItemResult> items;
  int get imported =>
      items.where((item) => item.status == ImportItemStatus.imported).length;
  int get skipped =>
      items.where((item) => item.status == ImportItemStatus.skipped).length;
  int get failed =>
      items.where((item) => item.status == ImportItemStatus.failed).length;
}

class ImportService {
  const ImportService({this.tipFileCodec = const TipFileCodec()});

  final TipFileCodec tipFileCodec;

  Future<bool> importTipBytes(
    Uint8List bytes, {
    TipImportConflictStrategy conflictStrategy = TipImportConflictStrategy.skip,
  }) async {
    final dto = tipFileCodec.decodeBytes(bytes);
    final existing = await _findExistingTipBook(dto.quotation);
    if (existing != null &&
        conflictStrategy == TipImportConflictStrategy.skip) {
      return false;
    }
    if (existing != null &&
        conflictStrategy == TipImportConflictStrategy.overwrite) {
      await globalDB.transaction(() async {
        await (globalDB.delete(globalDB.tipRecord)
              ..where((table) => table.bookId.equals(existing.id)))
            .go();
        await (globalDB.delete(globalDB.tipBook)
              ..where((table) => table.id.equals(existing.id)))
            .go();
        await _createTipBook(dto, useTransaction: false);
      });
      return true;
    }
    if (existing != null &&
        conflictStrategy == TipImportConflictStrategy.saveAsNew) {
      final book = dto.quotation;
      final copy = TipBookFileDto(
        schemaVersion: dto.schemaVersion,
        quotation: TipBookDto(
          name: await _availableBookName(book.name),
          remarks: book.remarks,
          image: book.image,
          version: book.version,
          productId: book.productId,
          records: book.records,
        ),
      );
      await _createTipBook(copy);
      return true;
    }
    await _createTipBook(dto);
    return true;
  }

  Future<List<TipImportPreview>> previewTipFiles(
      List<ImportFileRef> files) async {
    final previews = <TipImportPreview>[];
    for (final file in files) {
      final fileName = _resolvedFileName(file);
      try {
        if (path.extension(fileName).toLowerCase() != '.json') {
          previews
              .add(TipImportPreview(fileName: fileName, error: '不是 JSON 文件'));
          continue;
        }
        final dto = tipFileCodec.decodeBytes(await file.readBytes());
        previews.add(TipImportPreview(
          fileName: fileName,
          bookName: dto.quotation.name,
          conflict: await _findExistingTipBook(dto.quotation) != null,
        ));
      } catch (error) {
        previews
            .add(TipImportPreview(fileName: fileName, error: error.toString()));
      }
    }
    return previews;
  }

  Future<BatchImportResult> importTipFilesDetailed(
    List<ImportFileRef> files, {
    required TipImportConflictStrategy conflictStrategy,
  }) async {
    final results = <ImportItemResult>[];
    for (final file in files) {
      final fileName = _resolvedFileName(file);
      try {
        if (path.extension(fileName).toLowerCase() != '.json') {
          results.add(ImportItemResult(
              fileName: fileName,
              status: ImportItemStatus.skipped,
              message: '不是 JSON 文件'));
          continue;
        }
        final imported = await importTipBytes(
          await file.readBytes(),
          conflictStrategy: conflictStrategy,
        );
        results.add(ImportItemResult(
          fileName: fileName,
          status:
              imported ? ImportItemStatus.imported : ImportItemStatus.skipped,
          message: imported ? '导入成功' : '已存在，按策略跳过',
        ));
      } catch (error) {
        results.add(ImportItemResult(
            fileName: fileName,
            status: ImportItemStatus.failed,
            message: error.toString()));
      }
    }
    return BatchImportResult(results);
  }

  Future<int> importFiles({
    required String importType,
    required List<ImportFileRef> files,
  }) async {
    if (files.isEmpty) {
      return 0;
    }

    if (importType == 'kaishi') {
      return _importTipBooks(files);
    }
    return _importJingShuFiles(files, importType);
  }

  Future<int> _importJingShuFiles(
    List<ImportFileRef> files,
    String jingshuType,
  ) async {
    final list = await (globalDB.select(globalDB.jingShu)
          ..where((tbl) => tbl.type.like('%$jingshuType%'))
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();

    var count = 0;
    for (final file in files) {
      final fileName = _resolvedFileName(file);
      if (path.extension(fileName).toLowerCase() != '.pdf') {
        continue;
      }

      final filename = path.basenameWithoutExtension(fileName);
      final exists = list.any((o) => o.name == filename);
      if (exists) {
        continue;
      }

      final localFilePath = await _persistImportedFile(
        file: file,
        importType: jingshuType,
      );
      await _createJingShu(
        filePath: localFilePath,
        importFileName: fileName,
        jingshuType: jingshuType,
      );
      count++;
      // Give the UI/event loop a chance to breathe during large imports.
      await Future<void>.delayed(Duration.zero);
    }
    return count;
  }

  Future<int> _importTipBooks(List<ImportFileRef> files) async {
    var count = 0;
    for (final file in files) {
      final fileName = _resolvedFileName(file);
      if (path.extension(fileName).toLowerCase() != '.json') {
        continue;
      }

      if (await importTipBytes(await file.readBytes())) count++;
    }
    return count;
  }

  Future<TipBookData?> _findExistingTipBook(TipBookDto book) async {
    if (book.id != null && book.id!.trim().isNotEmpty) {
      final bySourceId = await (globalDB.select(globalDB.tipBook)
            ..where((table) => table.sourceId.equals(book.id!.trim())))
          .getSingleOrNull();
      if (bySourceId != null) return bySourceId;
    }
    final normalizedName = book.name.trim().toLowerCase();
    final books = await globalDB.select(globalDB.tipBook).get();
    for (final item in books) {
      if (item.name.trim().toLowerCase() == normalizedName) return item;
    }
    return null;
  }

  Future<String> _availableBookName(String baseName) async {
    final books = await globalDB.select(globalDB.tipBook).get();
    final names = books.map((item) => item.name.trim().toLowerCase()).toSet();
    var suffix = 2;
    var candidate = '$baseName（副本）';
    while (names.contains(candidate.toLowerCase())) {
      candidate = '$baseName（副本 $suffix）';
      suffix++;
    }
    return candidate;
  }

  Future<void> _createTipBook(TipBookFileDto file,
      {bool useTransaction = true}) async {
    final quotation = file.quotation;
    Future<void> insertBook() async {
      final bookId = await globalDB.tipBook.insertOne(
        TipBookCompanion.insert(
          name: quotation.name,
          image: quotation.image,
          remarks: Value(quotation.remarks),
          favoriteDateTime: const Value(null),
          createDateTime: Value(DateTime.now()),
          sourceId: Value(quotation.id),
          version: Value(quotation.version),
          sourceType: const Value('imported'),
          productId: Value(quotation.productId),
          updatedDateTime: Value(DateTime.now()),
        ),
      );

      for (var index = 0; index < quotation.records.length; index++) {
        final record = quotation.records[index];
        await globalDB.tipRecord.insertOne(
          TipRecordCompanion.insert(
            bookId: bookId,
            content: record.content,
            jsonId: Value(record.id),
            favoriteDateTime: Value(record.isFavorite ? DateTime.now() : null),
            completedDateTime: Value(record.completedDate),
            comments: Value(record.comments),
            tag: Value(record.tag),
            sortOrder: Value(index),
          ),
        );
      }
    }

    if (useTransaction) {
      await globalDB.transaction(insertBook);
    } else {
      await insertBook();
    }
  }

  String _resolvedFileName(ImportFileRef file) {
    if (file.name.trim().isNotEmpty) {
      return file.name;
    }
    return path.basename(file.path);
  }

  Future<String> _persistImportedFile({
    required ImportFileRef file,
    required String importType,
  }) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final importRoot = Directory(
      path.join(documentsDirectory.path, 'imports', importType),
    );
    if (!await importRoot.exists()) {
      await importRoot.create(recursive: true);
    }

    final fileName = _resolvedFileName(file);
    final targetFile = File(path.join(importRoot.path, fileName));
    await file.writeTo(targetFile);
    return targetFile.path;
  }

  Future<void> _createJingShu({
    required String filePath,
    required String importFileName,
    required String jingshuType,
  }) async {
    final filenamePdf = importFileName;
    final filenameWithoutPdf = path.basenameWithoutExtension(importFileName);
    final imagePath = jingshuType.contains('shanshu')
        ? 'assets/images/shanshu.png'
        : 'assets/images/jingshu.png';

    final item = JingShuCompanion(
      name: Value(filenameWithoutPdf),
      image: Value(imagePath),
      fileUrl: Value(filePath),
      fileType: const Value('pdf'),
      type: Value('external$jingshuType'),
      remarks: Value(filenamePdf),
      favoriteDateTime: const Value(null),
      createDateTime: Value(DateTime.now()),
    );
    await globalDB.into(globalDB.jingShu).insert(item);
  }
}
