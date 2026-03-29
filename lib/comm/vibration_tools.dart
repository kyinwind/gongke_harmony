import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VibrationTools {
  static const MethodChannel _channel = MethodChannel('gongke/vibration');

  static Future<void> vibrate() async {
    try {
      await _channel.invokeMethod('vibrate');
    } catch (e) {
      debugPrint('vibration error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      debugPrint('vibration stop error: $e');
    }
  }
}
