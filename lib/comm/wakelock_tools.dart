import 'package:flutter/services.dart';

class WakelockTools {
  static const MethodChannel _channel = MethodChannel('gongke/wakelock');
  //避免息屏
  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {}
  }
  //允许息屏
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {}
  }
}
