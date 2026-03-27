import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as path;

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
    final list = await globalDB.managers.jingShu
        .filter((f) => f.type.contains(jingshuType))
        .orderBy((t) => t.favoriteDateTime.desc() & t.name.asc())
        .get();

    var count = 0;
    for (final file in files) {
      final filePath = file.path;
      if (path.extension(filePath).toLowerCase() != '.pdf') {
        continue;
      }

      final filename = path.basenameWithoutExtension(filePath);
      final exists = list.any((o) => o.name == filename);
      if (exists) {
        continue;
      }

      await _createJingShu(filePath, jingshuType);
      count++;
    }
    return count;
  }

  Future<int> _importTipBooks(List<ImportFileRef> files) async {
    final tipList = await globalDB.managers.tipBook
        .orderBy((t) => t.favoriteDateTime.desc() & t.name.asc())
        .get();

    var count = 0;
    for (final file in files) {
      final filePath = file.path;
      if (path.extension(filePath).toLowerCase() != '.json') {
        continue;
      }

      final filename = path.basenameWithoutExtension(filePath);
      final exists = tipList.any((o) => o.name == filename);
      if (exists) {
        continue;
      }

      await _createTipBook(filePath);
      count++;
    }
    return count;
  }

  Future<void> _createTipBook(String filePath) async {
    final jsonString = await File(filePath).readAsString();
    final jsonData = json.decode(jsonString);

    await globalDB.transaction(() async {
      final quotation = jsonData['quotation'];
      final bookId = await globalDB.tipBook.insertOne(
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
    });
  }

  Future<void> _createJingShu(String filePath, String jingshuType) async {
    final filenamePdf = path.basename(filePath);
    final filenameWithoutPdf = path.basenameWithoutExtension(filePath);
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
