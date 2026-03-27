import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 获取当前 Android 的 API Level（例如 34 表示 Android 14）
  static Future<int?> get androidApiLevel async {
    if (!Platform.isAndroid) return null;
    final androidInfo = await _deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// 判断是否为 Android 14 (API 34) 或更高版本
  static Future<bool> get isAndroid14Above async {
    final level = await androidApiLevel;
    return level != null && level > 34;
  }

  /// 判断是否为 Android 平台
  static bool get isAndroid => Platform.isAndroid;

  /// 判断是否为 iOS 平台
  static bool get isIOS => Platform.isIOS;
}
