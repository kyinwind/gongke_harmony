import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:gongke/comm/file_import_adapter.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';

class ImportService {
  const ImportService();

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
    final tipList = await (globalDB.select(globalDB.tipBook)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();

    var count = 0;
    for (final file in files) {
      final fileName = _resolvedFileName(file);
      if (path.extension(fileName).toLowerCase() != '.json') {
        continue;
      }

      final filename = path.basenameWithoutExtension(fileName);
      final exists = tipList.any((o) => o.name == filename);
      if (exists) {
        continue;
      }

      await _createTipBook(file);
      count++;
    }
    return count;
  }

  Future<void> _createTipBook(ImportFileRef file) async {
    final jsonString = utf8.decode(await file.readBytes());
    final jsonData = json.decode(jsonString);
    int? bookId;
    try {
      final quotation = jsonData['quotation'];
      bookId = await globalDB.tipBook.insertOne(
        TipBookCompanion.insert(
          name: quotation['name'],
          image: quotation['image'],
          remarks: Value(quotation['remarks']),
          favoriteDateTime: const Value(null),
          createDateTime: Value(DateTime.now()),
        ),
      );

      final records = quotation['records'] as List<dynamic>;
      for (final recordData in records) {
        await globalDB.tipRecord.insertOne(
          TipRecordCompanion.insert(
            bookId: bookId,
            content: recordData['content'],
          ),
        );
      }
    } catch (e) {
      if (bookId != null) {
        try {
          await (globalDB.delete(globalDB.tipRecord)
                ..where((tbl) => tbl.bookId.equals(bookId!)))
              .go();
          await (globalDB.delete(globalDB.tipBook)
                ..where((tbl) => tbl.id.equals(bookId!)))
              .go();
        } catch (_) {}
      }
      rethrow;
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
