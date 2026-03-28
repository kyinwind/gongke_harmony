import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:flutter/services.dart';

bool appBuildFlag = false; // false,lite版本；true，完整功能版本
//别忘了同时修改pubspec.yaml文件，把pdfs，tips目录的注释去掉

enum FoPuShaImageType {
  amituofo('阿弥陀佛圣像'),
  dizangpusashengxiang('地藏菩萨圣像'),
  dashizhipusashengxiang('大势至菩萨圣像'),
  guanyinpusashengxiang('观音菩萨圣像'),
  guanshiyinpusashengxiang('观世音菩萨圣像'),
  shijiamounifoshengxiang('释迦牟尼佛圣像'),
  xifangsanshengxiang('西方三圣像');

  final String label;
  const FoPuShaImageType(this.label);
}

String getLabelByFoPuSaType(String typeString) {
  try {
    return FoPuShaImageType.values
        .firstWhere((type) => type.name == typeString)
        .label;
  } catch (e) {
    return '未知类型'; // 返回默认值
  }
}

String getFoPuSaImagePath(String label) {
  final type = getTypeByFoPuSaLabel(label);
  return 'assets/images/$type.jpg';
}

String getTypeByFoPuSaLabel(String fopusaLabel) {
  try {
    switch (fopusaLabel) {
      case '阿弥陀佛圣像':
        return 'amituofo';
      case '地藏菩萨圣像':
        return 'dizangpusashengxiang';
      case '大势至菩萨圣像':
        return 'dashizhipusashengxiang';
      case '观音菩萨圣像':
        return 'guanyinpusashengxiang';
      case '观世音菩萨圣像':
        return 'guanshiyinpusashengxiang';
      case '释迦牟尼佛圣像':
        return 'shijiamounifoshengxiang';
      case '西方三圣像':
        return 'xifangsanshengxiang';
      default:
        return 'xifangsanshengxiang';
    }
  } catch (e) {
    return 'xifangsanshengxiang'; // 返回默认值
  }
}

enum GongKeType {
  songjing('诵经'),
  nianzhou('念咒'),
  nianshenghao('念佛菩萨圣号'),
  ketou('磕头'),
  baichan('拜忏'),
  dazuo('打坐'),
  others('其他');

  final String label;
  const GongKeType(this.label);
}

String getLabelSafely(String typeString) {
  try {
    return GongKeType.values
        .firstWhere((type) => type.name == typeString)
        .label;
  } catch (e) {
    return '未知类型'; // 返回默认值
  }
}

String getDanWeiByLabel(String typeLabelString) {
  try {
    switch (typeLabelString) {
      case '诵经':
        return '部';
      case '念咒':
        return '遍';
      case '念圣号':
        return '声';
      case '磕头':
        return '个';
      case '拜忏':
        return '次';
      case '打坐':
        return '分钟';
      default:
        return '遍';
    }
  } catch (e) {
    return '遍'; // 返回默认值
  }
}

String getDanWei(String typeString) {
  try {
    switch (typeString) {
      case 'songjing':
        return '部';
      case 'nianzhou':
        return '遍';
      case 'nianshenghao':
        return '声';
      case 'ketou':
        return '个';
      case 'baichan':
        return '次';
      case 'dazuo':
        return '分钟';
      default:
        return '遍';
    }
  } catch (e) {
    return '遍'; // 返回默认值
  }
}

Future<Map<String, String>> getJingShuFiles() async {
  final results = await (globalDB.select(globalDB.jingShu)
        ..where((tbl) => tbl.type.like('%jingshu%')))
      .get();
  final map = <String, String>{};
  for (final item in results) {
    map[item.name] = item.fileUrl;
  }
  return map;
}

// // 定义经书名称到文件URL的映射
// final Map<String, String> jingShuFiles = {
//   '《一切如来心秘密全身舍利宝箧印陀罗尼经》': '1.pdf',
//   '《三劫三千佛名经》': '2.pdf',
//   '《佛教念诵集》（暮时课诵）': '3.pdf',
//   '《佛教念诵集》（朝时课诵）': '4.pdf',
//   '《佛说七俱胝佛母心大准提陀罗尼经》': '5.pdf',
//   '《佛说四十二章经》': '6.pdf',
//   '《佛说无量寿经》': '7.pdf',
//   '《佛说父母恩难报经》': '8.pdf',
//   '《佛说疗痔病经》': '9.pdf',
//   '《佛说盂兰盆经》': '10.pdf',
//   '《佛说观弥勒菩萨上生兜率陀天经》': '11.pdf',
//   '《佛说观弥勒菩萨下生经》': '12.pdf',
//   '《佛说阿弥陀经要解》': '13.pdf',
//   '《僧伽吒经》': '14.pdf',
//   '《六祖大师法宝坛经》': '15.pdf',
//   '《净土五经》': '16.pdf',
//   '《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》': '17.pdf',
//   '《大乘入楞伽经》': '18.pdf',
//   '《大佛顶首楞严神咒》': '19.pdf',
//   '《大佛顶首楞严经》': '20.pdf',
//   '《大悲咒》（84句）': '22.pdf',
//   '《大方广佛华严经普贤菩萨行愿品》': '23.pdf',
//   '《大方广圆觉修多罗了义经》': '24.pdf',
//   '《妙法莲华经》': '25.pdf',
//   '《慈悲药师宝忏》': '26.pdf',
//   '《慈悲道场忏法》': '27.pdf',
//   '《梵网经菩萨戒本》诵戒专用': '28.pdf',
//   '《礼佛大忏悔文》': '29.pdf',
//   '《维摩诘所说经》': '30.pdf',
//   '《药师琉璃光如来本愿功德经》': '31.pdf',
//   '《虚空藏菩萨经》': '32.pdf',
//   '《观世音菩萨普门品》': '33.pdf',
//   '《观世音菩萨耳根圆通章》': '34.pdf',
//   '《解深密经》': '35.pdf',
//   '《达磨大师血脉论》': '36.pdf',
//   '《金光明经》': '37.pdf',
//   '《金刚般若波罗蜜经》': '38.pdf',
//   '地藏三经《占察善恶业报经》': '39.pdf',
//   '地藏三经《地藏菩萨本愿经》': '40.pdf',
//   '地藏三经《地藏菩萨本愿经》（仿瓷版）': '41.pdf',
//   '地藏三经《大乘大集地藏十轮经》': '42.pdf',
//   '《大方广佛华严经》': '43.pdf',
//   '《大佛顶首楞严经浅释》宣化上人': '10000.pdf',
//   '广钦老和尚事迹-开示录': '10001.pdf',
//   '宽净法师-西方极乐世界游记': '10002.pdf',
//   '倓虚法师-影尘回忆录': '10003.pdf',
//   '黄念祖居士点滴开示': '10004.pdf',
//   '果卿居士-现代因果实录(一)': '10005.pdf',
//   '果卿居士-现代因果实录(二)': '10006.pdf',
//   '果卿居士-现代因果实录(三)': '10007.pdf',
//   '了凡四训': '10008.pdf',
//   '于凌波居士-向知识分子介绍佛教': '10009.pdf',
//   '坐禅': '10010.pdf',
//   '坐禅之问答录': '10011.pdf',
//   '坐禅2·次世代版终极佛法': '10012.pdf',
//   '《心经》吕新国讲解': '10013.pdf',
//   '《金刚经》吕新国讲解': '10014.pdf',
// };

// Future<String> getPdfFileByName(String jingShuName) async {
//   final jingShuFiles = await getJingShuFiles();
//   return jingShuFiles[jingShuName] ?? '';
// }

Future<JingShuData> getJingShuByName(String jingShuName) async {
  final jingshu = await (globalDB.select(globalDB.jingShu)
        ..where((tbl) => tbl.name.equals(jingShuName)))
      .getSingleOrNull();
  JingShuData nullvalue = JingShuData(
    id: 0,
    createDateTime: DateTime.now(),
    name: '未找到${jingShuName}',
    type: 'jingshu',
    image: '',
    fileUrl: '',
    fileType: 'pdf',
    muyu: false,
    bkMusic: false,
  );
  return jingshu ?? nullvalue;
}

Future<String> getJingShuNameByFile(String filename) async {
  final jingShuFiles = await getJingShuFiles();
  return jingShuFiles.entries
      .firstWhere(
        (entry) => entry.value == filename,
        orElse: () => MapEntry('', ''),
      )
      .key;
}

class AppButtonStyle {
  static final primaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade300;
      }
      return Colors.blue.shade600;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevation: WidgetStateProperty.resolveWith<double>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return 0;
      }
      return 2;
    }),
    minimumSize: WidgetStateProperty.all(const Size(120, 45)),
  );

  static final secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade300;
      }
      return Colors.green.shade600;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevation: WidgetStateProperty.resolveWith<double>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return 0;
      }
      return 2;
    }),
    minimumSize: WidgetStateProperty.all(const Size(120, 45)),
  );
}

String? imagePath = 'assets/images/jingshu.png';
List<JingShuCompanion> jingShuList = [
  JingShuCompanion(
    name: Value('《一切如来心秘密全身舍利宝箧印陀罗尼经》'),
    image: Value(imagePath!),
    fileUrl: Value('1.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《一切如来心秘密全身舍利宝箧印陀罗尼经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《三劫三千佛名经》'),
    image: Value(imagePath!),
    fileUrl: Value('2.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《三劫三千佛名经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛教念诵集》（暮时课诵）'),
    image: Value(imagePath!),
    fileUrl: Value('3.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛教念诵集》（暮时课诵）'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛教念诵集》（朝时课诵）'),
    image: Value(imagePath!),
    fileUrl: Value('4.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛教念诵集》（朝时课诵）'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说七俱胝佛母心大准提陀罗尼经》'),
    image: Value(imagePath!),
    fileUrl: Value('5.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说七俱胝佛母心大准提陀罗尼经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说四十二章经》'),
    image: Value(imagePath!),
    fileUrl: Value('6.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说四十二章经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说无量寿经》'),
    image: Value(imagePath!),
    fileUrl: Value('7.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说无量寿经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说父母恩难报经》'),
    image: Value(imagePath!),
    fileUrl: Value('8.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说父母恩难报经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说疗痔病经》'),
    image: Value(imagePath!),
    fileUrl: Value('9.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说疗痔病经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说盂兰盆经》'),
    image: Value(imagePath!),
    fileUrl: Value('10.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说盂兰盆经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说观弥勒菩萨上生兜率陀天经》'),
    image: Value(imagePath!),
    fileUrl: Value('11.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说观弥勒菩萨上生兜率陀天经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说观弥勒菩萨下生经》'),
    image: Value(imagePath!),
    fileUrl: Value('12.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说观弥勒菩萨下生经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《佛说阿弥陀经要解》'),
    image: Value(imagePath!),
    fileUrl: Value('13.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《佛说阿弥陀经要解》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《僧伽吒经》'),
    image: Value(imagePath!),
    fileUrl: Value('14.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《僧伽吒经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《六祖大师法宝坛经》'),
    image: Value(imagePath!),
    fileUrl: Value('15.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《六祖大师法宝坛经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《净土五经》'),
    image: Value(imagePath!),
    fileUrl: Value('16.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《净土五经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》'),
    image: Value(imagePath!),
    fileUrl: Value('17.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大乘入楞伽经》'),
    image: Value(imagePath!),
    fileUrl: Value('18.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大乘入楞伽经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大佛顶首楞严神咒》'),
    image: Value(imagePath!),
    fileUrl: Value('19.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大佛顶首楞严神咒》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大佛顶首楞严经》'),
    image: Value(imagePath!),
    fileUrl: Value('20.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大佛顶首楞严经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大悲咒》（84句）'),
    image: Value(imagePath!),
    fileUrl: Value('22.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大悲咒》（84句）'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大方广佛华严经普贤菩萨行愿品》'),
    image: Value(imagePath!),
    fileUrl: Value('23.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大方广佛华严经普贤菩萨行愿品》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大方广圆觉修多罗了义经》'),
    image: Value(imagePath!),
    fileUrl: Value('24.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大方广圆觉修多罗了义经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《妙法莲华经》'),
    image: Value(imagePath!),
    fileUrl: Value('25.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《妙法莲华经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《慈悲药师宝忏》'),
    image: Value(imagePath!),
    fileUrl: Value('26.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《慈悲药师宝忏》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《慈悲道场忏法》'),
    image: Value(imagePath!),
    fileUrl: Value('27.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《慈悲道场忏法》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《梵网经菩萨戒本》诵戒专用'),
    image: Value(imagePath!),
    fileUrl: Value('28.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《梵网经菩萨戒本》诵戒专用'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《礼佛大忏悔文》'),
    image: Value(imagePath!),
    fileUrl: Value('29.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《礼佛大忏悔文》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《维摩诘所说经》'),
    image: Value(imagePath!),
    fileUrl: Value('30.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《维摩诘所说经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《药师琉璃光如来本愿功德经》'),
    image: Value(imagePath!),
    fileUrl: Value('31.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《药师琉璃光如来本愿功德经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《虚空藏菩萨经》'),
    image: Value(imagePath!),
    fileUrl: Value('32.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《虚空藏菩萨经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《观世音菩萨普门品》'),
    image: Value(imagePath!),
    fileUrl: Value('33.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《观世音菩萨普门品》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《观世音菩萨耳根圆通章》'),
    image: Value(imagePath!),
    fileUrl: Value('34.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《观世音菩萨耳根圆通章》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《解深密经》'),
    image: Value(imagePath!),
    fileUrl: Value('35.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《解深密经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《达磨大师血脉论》'),
    image: Value(imagePath!),
    fileUrl: Value('36.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《达磨大师血脉论》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《金光明经》'),
    image: Value(imagePath!),
    fileUrl: Value('37.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《金光明经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《金刚般若波罗蜜经》'),
    image: Value(imagePath!),
    fileUrl: Value('38.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《金刚般若波罗蜜经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('地藏三经《占察善恶业报经》'),
    image: Value(imagePath!),
    fileUrl: Value('39.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('地藏三经《占察善恶业报经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('地藏三经《地藏菩萨本愿经》'),
    image: Value(imagePath!),
    fileUrl: Value('40.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('地藏三经《地藏菩萨本愿经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('地藏三经《地藏菩萨本愿经》（仿瓷版）'),
    image: Value(imagePath!),
    fileUrl: Value('41.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('地藏三经《地藏菩萨本愿经》（仿瓷版）'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('地藏三经《大乘大集地藏十轮经》'),
    image: Value(imagePath!),
    fileUrl: Value('42.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('地藏三经《大乘大集地藏十轮经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《大方广佛华严经》'),
    image: Value(imagePath!),
    fileUrl: Value('43.pdf'),
    fileType: Value('pdf'),
    type: Value('jingshu'),
    remarks: Value('《大方广佛华严经》'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
];

List<JingShuCompanion> shanShuList = [
  JingShuCompanion(
    name: Value('《大佛顶首楞严经浅释》宣化上人'),
    image: Value('assets/images/lengyanjingqianshi.jpeg'),
    fileUrl: Value('10000.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('《大佛顶首楞严经浅释》宣化上人'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('广钦老和尚事迹-开示录'),
    image: Value('assets/images/guangqinlaoheshang.jpg'),
    fileUrl: Value('10001.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('广钦老和尚事迹-开示录'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('宽净法师-西方极乐世界游记'),
    image: Value('assets/images/kuanjingfashi.png'),
    fileUrl: Value('10002.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('宽净法师-西方极乐世界游记'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('倓虚法师-影尘回忆录'),
    image: Value('assets/images/tanxufashi.jpg'),
    fileUrl: Value('10003.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('倓虚法师-影尘回忆录'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('黄念祖居士点滴开示'),
    image: Value('assets/images/huangnianzhujushi.jpeg'),
    fileUrl: Value('10004.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('黄念祖居士点滴开示'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('果卿居士-现代因果实录(一)'),
    image: Value('assets/images/xiandaiiynguoshilu.jpeg'),
    fileUrl: Value('10005.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('果卿居士-现代因果实录(一)'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('果卿居士-现代因果实录(二)'),
    image: Value('assets/images/xiandaiiynguoshilu.jpeg'),
    fileUrl: Value('10006.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('果卿居士-现代因果实录(二)'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('果卿居士-现代因果实录(三)'),
    image: Value('assets/images/xiandaiiynguoshilu.jpeg'),
    fileUrl: Value('10007.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('果卿居士-现代因果实录(三)'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('了凡四训'),
    image: Value('assets/images/liaofansixun.jpg'),
    fileUrl: Value('10008.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('了凡四训'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('于凌波居士-向知识分子介绍佛教'),
    image: Value('assets/images/jieshaofojiao.jpeg'),
    fileUrl: Value('10009.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('于凌波居士-向知识分子介绍佛教'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('坐禅'),
    image: Value('assets/images/zuochan.jpeg'),
    fileUrl: Value('10010.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('坐禅'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('坐禅之问答录'),
    image: Value('assets/images/zuochanwendalu.jpeg'),
    fileUrl: Value('10011.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('坐禅之问答录'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('坐禅2·次世代版终极佛法'),
    image: Value('assets/images/zuochan2.jpeg'),
    fileUrl: Value('10012.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('坐禅2·次世代版终极佛法'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《心经》吕新国讲解'),
    image: Value('assets/images/xinjing-lvxinguo.png'),
    fileUrl: Value('10013.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('《心经》吕新国讲解'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
  JingShuCompanion(
    name: Value('《金刚经》吕新国讲解'),
    image: Value('assets/images/jingangjing-lvxinguo.jpg'),
    fileUrl: Value('10014.pdf'),
    fileType: Value('pdf'),
    type: Value('shanshu'),
    remarks: Value('《金刚经》吕新国讲解'),
    favoriteDateTime: Value(null),
    createDateTime: Value(DateTime.now()),
  ),
];

final List<Map<String, String>> help_slides_android = [
  {
    'image': 'assets/help/01.jpg',
    'title': '首页',
    'description': '发愿功课，功课完成日历一目了然',
  },
  {
    'image': 'assets/help/02.jpg',
    'title': '发愿向导',
    'description': '跟随发愿向导，制定功课计划。',
  },
  {
    'image': 'assets/help/03.jpg',
    'title': '完成功课记录',
    'description': '点击日历日期，完成当天功课。',
  },
  {
    'image': 'assets/help/04.jpg',
    'title': '小工具-功课计数',
    'description': '对于念咒类功课，提供晃动手机计数功能，适合在外散步时做功课。',
  },
  {
    'image': 'assets/help/05.jpg',
    'title': '小工具-念佛计数',
    'description': '对于念佛类功课，提供电子木鱼功能',
  },
  {
    'image': 'assets/help/06.jpg',
    'title': '功课统计',
    'description': '可随时查看统计功课完成情况',
  },
  {
    'image': 'assets/help/07.jpg',
    'title': '藏经阁',
    'description': '40多部常用经书供持诵学习',
  },
  {
    'image': 'assets/help/08.jpg',
    'title': '大德开示',
    'description': '每天一句大德开示，勉励自己精进修行。',
  },
  {
    'image': 'assets/help/09.jpg',
    'title': '拜忏',
    'description': '根据自己体力和发愿，自定义人声引导拜忏，自净其意。',
  },
  {
    'image': 'assets/help/10.jpg',
    'title': '文件导入',
    'description': '本app不包含经书、善书和开示文件，需要用户自己导入使用，请关注app技术支持网站。',
  },
];

final List<Map<String, String>> help_slides_windows = [
  {
    'image': 'assets/help/101.png',
    'title': '首页',
    'description': '发愿功课，功课完成日历一目了然',
  },
  {
    'image': 'assets/help/102.png',
    'title': '发愿向导',
    'description': '跟随发愿向导，制定功课计划。',
  },
  {
    'image': 'assets/help/103.png',
    'title': '完成功课记录',
    'description': '点击日历日期，完成当天功课。\n如果您使用本软件感觉很好，请分享给好友。',
  },
  {
    'image': 'assets/help/104.png',
    'title': '双页显示经书',
    'description': '使用空格，回车翻页，使用上下键切换页。',
  },
  {
    'image': 'assets/help/105.png',
    'title': '完成功课小工具-功课计数',
    'description': '对于念咒类功课，提供计数小工具。\n同样对于念佛、打坐提供电子木鱼和打坐计时工具。',
  },
  {
    'image': 'assets/help/106.png',
    'title': '双页显示善书，单页显示可以听书',
    'description': '可以记住上一次读到的页码，下次打开时直接从上次页码开始。\n单页显示时可以听书。',
  },
  {
    'image': 'assets/help/107.png',
    'title': '大德开示',
    'description': '每天一句大德开示，勉励自己精进修行。',
  },
  {
    'image': 'assets/help/108.png',
    'title': '拜忏',
    'description': '根据自己体力和发愿，自定义人声引导拜忏，自净其意。',
  },
  {
    'image': 'assets/help/109.png',
    'title': '文件导入',
    'description': '本app不包含经书、善书和开示文件，需要用户自己导入使用，请关注app技术支持网站。',
  },
];

List<Map<String, String>> getHelpSlidesForWidth(double width) {
  if (width >= 900) {
    return help_slides_windows;
  }
  return help_slides_android;
}

// 复制文本到系统剪贴板
void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text))
      .then((_) {
        // 复制成功后的回调，可以在这里显示提示信息
        print('内容已复制到剪贴板');
      })
      .catchError((error) {
        // 复制失败的处理
        print('复制失败: $error');
      });
}
