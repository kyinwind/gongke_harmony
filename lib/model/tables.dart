import 'package:drift/drift.dart';

class SoftwareVersion extends Table with AutoIncrementingPrimaryKey {
  TextColumn get versionname => text()();
  TextColumn get versionPubTime => text()();
  TextColumn get versionChange => text()();

  IntColumn get sortOrder => integer()(); // For maintaining sort order
}

class BaiChan extends Table
    with
        AutoIncrementingPrimaryKey,
        CreateDateTimeColumn,
        FavoriteDateTimeColumn,
        RemarksColumn {
  TextColumn get name => text()();
  TextColumn get image => text()();
  TextColumn get chanhuiWenStart => text()();
  TextColumn get chanhuiWenEnd => text()();
  IntColumn get baichanTimes => integer().withDefault(const Constant(88))();
  IntColumn get baichanInterval1 =>
      integer().withDefault(const Constant(7))(); //每一拜花费的时间 单位秒
  IntColumn get baichanInterval2 =>
      integer().withDefault(const Constant(5))(); //每一拜之间间隔的时间 单位秒
  BoolColumn get flagOrderNumber =>
      boolean().withDefault(const Constant(true))(); //每一拜，是否含序号，即第几拜
  BoolColumn get flagQiShen =>
      boolean().withDefault(const Constant(true))(); //每一拜，是否喊起身
  TextColumn get detail =>
      text().nullable()(); //为后续增加自定义功能预备，可以定义每一拜的佛名号，以及之前说什么，之后说什么
}

class FaYuan extends Table
    with
        AutoIncrementingPrimaryKey,
        CreateDateTimeColumn,
        ModifyDateTimeColumn,
        RemarksColumn {
  TextColumn get name => text()();
  TextColumn get fodiziname => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get yuanwang => text()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  TextColumn get fayuanwen => text()(); //是合并起来显示的发愿文
  TextColumn get sts =>
      text().withDefault(const Constant('A'))(); //A代表正常，D代表已过期，成为历史数据
  RealColumn get percentValue => real().withDefault(const Constant(0.0))();
}

///
///功课类型多种多样，有诵经、念咒、念佛菩萨圣号，磕头、拜忏，等多种
///如果是诵经，则name保存经书名称，如果是念咒，则name保存咒名，如果是念圣号，则name保存是哪位佛菩萨，如果是磕头，则name保存是磕大头还是磕小头，如果是拜忏，则name保存是哪种忏法
///默认功课是诵经
///
//enum GongKeType:String, Codable {
//    case songjing
//    case nianzhou
//    case nianshenghao
//    case ketou
//    case baichan
//    case dazuo
//    case others
//}
class GongKeItemsOneDay extends Table with AutoIncrementingPrimaryKey {
  IntColumn get fayuanId => integer()();
  TextColumn get gongketype => text().withDefault(const Constant('songjing'))();
  TextColumn get name => text()();
  IntColumn get cnt => integer().withDefault(const Constant(0))();
  IntColumn get idx =>
      integer().withDefault(const Constant(0))(); //功课项的序号，与GongKeItem的idx对应
}

class GongKeItem extends Table
    with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
  TextColumn get name => text()();
  IntColumn get fayuanId => integer()();
  TextColumn get gongketype => text()();
  IntColumn get cnt => integer().withDefault(const Constant(0))(); // 遍数
  TextColumn get gongKeDay => text()(); // 是哪一天的功课
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  IntColumn get idx => integer().withDefault(const Constant(0))(); // 功课项的排序
  IntColumn get curCnt => integer().withDefault(const Constant(0))(); // 当前完成的遍数
}

class JingShu extends Table
    with
        AutoIncrementingPrimaryKey,
        CreateDateTimeColumn,
        FavoriteDateTimeColumn,
        RemarksColumn {
  TextColumn get name => text()();
  TextColumn get type =>
      text()(); //jingshu,shanshu(内置经书和善书),externaljingshu,externalshanshu（外部导入的经书和善书）
  TextColumn get image => text()();
  TextColumn get fileUrl => text()();
  TextColumn get fileType => text()();
  BoolColumn get muyu => boolean().withDefault(const Constant(false))();
  BoolColumn get bkMusic => boolean().withDefault(const Constant(false))();
  TextColumn get bkMusicname => text().nullable()();
  TextColumn get muyuName => text().nullable()();
  TextColumn get muyuImage => text().nullable()();
  TextColumn get muyuType => text().nullable()();
  IntColumn get muyuCount => integer().nullable()();
  RealColumn get muyuInterval => real().nullable()();
  RealColumn get muyuDuration => real().nullable()();
  IntColumn get curPageNum => integer().nullable()(); // 当前看到的页码
}

class TipBook extends Table
    with
        AutoIncrementingPrimaryKey,
        CreateDateTimeColumn,
        FavoriteDateTimeColumn,
        RemarksColumn {
  TextColumn get name => text()();
  TextColumn get image => text()();
}

class TipRecord extends Table
    with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
  TextColumn get content => text()();
  IntColumn get bookId => integer()();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

mixin CreateDateTimeColumn on Table {
  DateTimeColumn get createDateTime =>
      dateTime().withDefault(currentDateAndTime)();
}

mixin FavoriteDateTimeColumn on Table {
  DateTimeColumn get favoriteDateTime => dateTime().nullable()(); // 用于标记是否为最爱
}

mixin ModifyDateTimeColumn on Table {
  DateTimeColumn get modifyDateTime =>
      dateTime().withDefault(currentDateAndTime)(); // 用于记录修改时间
}

mixin RemarksColumn on Table {
  TextColumn get remarks => text().nullable()(); // 用于记录备注信息
  TextColumn get bk1 => text().nullable()(); // 备用字段1
  TextColumn get bk2 => text().nullable()(); // 备用字段2
}
