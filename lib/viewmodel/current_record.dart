import 'package:gongke/main.dart';
import 'package:gongke/comm/today_tip_service.dart';

class CurrentRecord {
  String content;
  String comments;
  int bookId;
  String bookName;
  String bookImage;
  int id;
  DateTime? favoriteDateTime;
  DateTime? completedDateTime;

  CurrentRecord({
    this.content = '暂时无数据',
    this.comments = '',
    this.bookId = 0,
    this.id = 0,
    this.bookName = '',
    this.bookImage = '',
    this.favoriteDateTime,
    this.completedDateTime,
  });
}

// class TipRecord extends Table
//     with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
//   TextColumn get content => text()();
//   IntColumn get bookId => integer()();
// }
Future<CurrentRecord> getCurrentRecord() async {
  final mode = await TodayTipSettings.loadMode();
  final fallback = DateTime.tryParse(firstDate ?? '');
  final startDate = await TodayTipSettings.loadStartDate(fallback: fallback);
  final selected = await TodayTipService(globalDB).select(
    now: DateTime.now(),
    startDate: startDate,
    mode: mode,
  );
  if (selected == null) return CurrentRecord();
  return CurrentRecord(
    id: selected.record.id,
    bookId: selected.book.id,
    content: selected.record.content,
    comments: selected.record.comments,
    bookName: selected.book.name,
    bookImage: selected.book.image,
    favoriteDateTime: selected.record.favoriteDateTime,
    completedDateTime: selected.record.completedDateTime,
  );
}
