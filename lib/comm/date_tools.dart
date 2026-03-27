import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';

class DateTools {
  // Get month string in "yyyy-MM" format from Date
  static String getMonthStringByDate(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  // Get month string in "yyyy-MM" format from date string
  static String getMonthStringByDateString(String date) {
    DateTime dateTime = getDateByString(date, 'yyyy-MM-dd');
    return DateFormat('yyyy-MM').format(dateTime);
  }

  // Get date string in "yyyy-MM-dd" format from Date
  static String getStringByDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Get datetime string in "yyyy-MM-dd HH:mm:ss" format
  static String getStringByDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  // Get current date in "yyyy-MM-dd" format
  static String getStringByCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Convert Date to string with custom format
  static String getDateStringByDate(
    DateTime date, {
    String dateFormat = 'yyyy-MM-dd',
  }) {
    return DateFormat(dateFormat).format(date).split(' ').first;
  }

  // Get month string from date with custom format
  static String getMonthStringByDateWithFormat(
    DateTime date, {
    String dateFormat = 'yyyy-MM',
  }) {
    return DateFormat(dateFormat).format(date).split(' ').first;
  }

  // Convert string to Date with format
  static DateTime getDateByString(String dateStr, String format) {
    return DateFormat(format).parse(dateStr);
  }

  // Convert month string to Date
  static DateTime getDateByMonthString(String monthStr) {
    return DateFormat('yyyy-MM').parse(monthStr);
  }

  // Convert number to percentage string
  static String getPercentageByNumber(double number) {
    return NumberFormat.percentPattern().format(number);
  }

  // Get days difference between two dates
  static int getDateDiff(String start, String end) {
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(start);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(end);
    return endDate.difference(startDate).inDays;
  }

  // Get days difference between two DateTime objects
  static int getDateDiffFromDateTime(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Get date after specified months
  static DateTime getDayAfterMonths(DateTime startDate, int months) {
    return DateTime(startDate.year, startDate.month + months, startDate.day);
  }

  // Get date before specified months
  static DateTime getDayBeforeMonths(DateTime startDate, int months) {
    return DateTime(startDate.year, startDate.month - months, startDate.day);
  }

  // Get date after specified days
  static DateTime getDateAfterDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  // Buddha holiday dictionary
  static const Map<String, String> buddhaHoliDay = {
    '1-1': '正月初一弥勒菩萨圣诞',
    '1-6': '正月初六定光佛圣诞',
    '2-8': '二月初八释迦牟尼佛出家',
    "2-15": "二月十五日释迦牟尼佛涅",
    "2-19": "二月十九日观音菩萨圣诞",
    "2-21": "二月二十一日普贤菩萨圣诞",
    "3-16": "三月十六日准提菩萨圣诞",
    "4-4": "四月初四文殊菩萨圣诞",
    "4-8": "四月初八释迦牟尼佛圣诞",
    "4-28": "四月二十八日药王菩萨圣诞",
    "5-13": "五月十三日伽蓝菩萨圣诞",
    "6-3": "六月初三韦驮菩萨圣诞",
    "6-19": "六月十九日观音菩萨成道",
    "7-13": "七月十三日大势至菩萨圣诞",
    "7-15": "七月十五日佛欢喜日",
    "7-24": "七月二十四日龙树菩萨圣诞",
    "7-30": "七月三十日地藏菩萨圣诞",
    "8-15": "八月十五日月光菩萨圣诞",
    "8-22": "八月二十二日燃灯古佛圣诞",
    "9-19": "九月十九日观音菩萨出家",
    "9-30": "九月三十日药师佛圣诞",
    "11-17": "十一月十七日阿弥陀佛圣诞",
    "11-19": "十一月十九日日光菩萨圣诞",
    "12-8": "十二月初八释迦牟尼佛成道",
    "12-23": "十二月二十三日监斋菩萨圣诞",
    "12-29": "十二月二十九日华严菩萨圣诞",
  };

  // 获取农历日期
  static String getLunarDate(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return '${lunar.getYearInChinese()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  }

  // 获取农历月日（不带年份）
  static String getLunarMonthDay(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  }

  // 获取农历节日
  static String? getLunarFestival(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getFestivals().isNotEmpty ? lunar.getFestivals()[0] : null;
  }

  // 修改 getBuddhaHolidayInfo 方法以使用农历日期
  static String getBuddhaHolidayInfo(DateTime date) {
    final lunar = Lunar.fromDate(date);
    String lunarKey = '${lunar.getMonth()}-${lunar.getDay()}';
    return buddhaHoliDay[lunarKey] ?? '';
  }

  // 公历转农历
  static DateTime solarToLunar(DateTime solar) {
    final lunar = Lunar.fromDate(solar);
    return DateTime(lunar.getYear(), lunar.getMonth(), lunar.getDay());
  }

  // 农历转公历
  static DateTime lunarToSolar(
    int year,
    int month,
    int day, {
    bool isLeap = false,
  }) {
    final lunar = Lunar.fromYmd(year, month, day);
    final solar = lunar.getSolar();
    return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
  }

  // Get Buddha days text
  static String getBuddhaDaysText() {
    return '''
正月初一弥勒菩萨圣诞
正月初六定光佛圣诞
二月初八释迦牟尼佛出家
二月十五日释迦牟尼佛涅
二月十九日观音菩萨圣诞
二月二十一日普贤菩萨圣诞
三月十六日准提菩萨圣诞
四月初四文殊菩萨圣诞
四月初八释迦牟尼佛圣诞
四月二十八日药王菩萨圣诞
五月十三日伽蓝菩萨圣诞
六月初三韦驮菩萨圣诞
六月十九日观音菩萨成道
七月十三日大势至菩萨圣诞
七月十五日佛欢喜日
七月二十四日龙树菩萨圣诞
七月三十日地藏菩萨圣诞
八月十五日月光菩萨圣诞
八月二十二日燃灯古佛圣诞
九月十九日观音菩萨出家
九月三十日药师佛圣诞
十一月十七日阿弥陀佛圣诞
十一月十九日日光菩萨圣诞
十二月初八释迦牟尼佛成道
十二月二十三日监斋菩萨圣诞
十二月二十九日华严菩萨圣诞
''';
  }
}
