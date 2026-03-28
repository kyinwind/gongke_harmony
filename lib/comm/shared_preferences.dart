import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

final Map<String, Object?> _fallbackValues = {};

Future<SharedPreferences?> _safePrefs() async {
  try {
    return await SharedPreferences.getInstance();
  } on MissingPluginException {
    return null;
  }
}

Future<void> saveBoolValue(String key, bool value) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    _fallbackValues[key] = value;
    return;
  }
  await prefs.setBool(key, value);
}

// 存储整数
Future<void> saveIntValue(String key, int value) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    _fallbackValues[key] = value;
    return;
  }
  await prefs.setInt(key, value);
}

// 存储字符串
Future<void> saveStringValue(String key, String value) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    _fallbackValues[key] = value;
    return;
  }
  await prefs.setString(key, value);
}

// 存储字符串列表
Future<void> saveStringListValue(String key, List<String> value) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    _fallbackValues[key] = value;
    return;
  }
  await prefs.setStringList(key, value);
}

// 读取布尔值
Future<bool?> getBoolValue(String key) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    return _fallbackValues[key] as bool?;
  }
  return prefs.getBool(key);
}

// 读取整数
Future<int?> getIntValue(String key) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    return _fallbackValues[key] as int?;
  }
  return prefs.getInt(key);
}

// 读取字符串
Future<String?> getStringValue(String key) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    return _fallbackValues[key] as String?;
  }
  return prefs.getString(key);
}

// 读取字符串列表
Future<List<String>?> getStringListValue(String key) async {
  final prefs = await _safePrefs();
  if (prefs == null) {
    return _fallbackValues[key] as List<String>?;
  }
  return prefs.getStringList(key);
}

// 存储日期（仅年月日）
Future<void> saveDateValue(String key, DateTime value) async {
  final String dateStr = DateFormat('yyyy-MM-dd').format(value);
  final prefs = await _safePrefs();
  if (prefs == null) {
    _fallbackValues[key] = dateStr;
    return;
  }
  await prefs.setString(key, dateStr);
}

// 读取日期（仅年月日）
Future<String?> getDateValue(String key) async {
  final prefs = await _safePrefs();
  final String? dateString = prefs == null
      ? _fallbackValues[key] as String?
      : prefs.getString(key);
  if (dateString == null) return null;
  return dateString;
}
