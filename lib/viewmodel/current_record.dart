import 'package:gongke/comm/date_tools.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/main.dart';
import 'package:intl/intl.dart';
import 'package:gongke/database.dart';
import 'package:drift/drift.dart' hide Column;

class CurrentRecord {
  String content;
  int bookId;
  String bookName;
  String bookImage;
  int id;

  CurrentRecord({
    this.content = '暂时无数据',
    this.bookId = 0,
    this.id = 0,
    this.bookName = '',
    this.bookImage = '',
  });
}

// class TipRecord extends Table
//     with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
//   TextColumn get content => text()();
//   IntColumn get bookId => integer()();
// }
Future<CurrentRecord> getCurrentRecord() async {
  final difference = DateTime.now()
      .difference(DateFormat('yyyy-MM-dd').parse(firstDate!))
      .inDays;
  final seq = difference + 1;
  print('-------------应该读取第${seq}个记录');
  var curRecord = CurrentRecord();

  // 获取所有按照favoriteDateTime和createDateTime排序的tipbooks
  final books = await (globalDB.select(globalDB.tipBook)
        ..orderBy([
          (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
          (tbl) => OrderingTerm.desc(tbl.createDateTime),
        ]))
      .get();

  List<TipRecordData> allRecords = [];

  // 遍历每个tipbook获取其对应的tiprecords
  for (var book in books) {
    final temprecords = await (globalDB.select(globalDB.tipRecord)
          ..where((tbl) => tbl.bookId.equals(book.id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]))
        .get();
    //print('Book: ${book.name}, Records Count: ${temprecords.length}');
    allRecords.addAll(temprecords);
    // 打印前五个记录的id
    // for (var i = 0; i < 5 && i < allRecords.length; i++) {
    //   print('Record ${i + 1} ID: ${allRecords[i].id}');
    // }
  }
  //对seq针对allRecords.length的长度求余
  if (allRecords.isEmpty) {
    return curRecord; // 或者返回 null，或给出默认值
  }
  final newseq = seq % allRecords.length;
  // 如果有足够的记录，获取第seq个记录
  if (allRecords.length >= newseq && newseq >= 0) {
    final record = allRecords[newseq - 1];
    curRecord.id = record.id;
    curRecord.content = record.content;

    // 获取对应的tipbook信息
    final book = await (globalDB.select(globalDB.tipBook)
          ..where((tbl) => tbl.id.equals(record.bookId)))
        .getSingle();
    curRecord.bookName = book.name;
    curRecord.bookImage = book.image;
  }

  return curRecord;
}
