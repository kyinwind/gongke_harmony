import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLauncherTools {
  static const MethodChannel _channel =
      MethodChannel('gongke/external_launcher');

  static Future<void> launch(String link) async {
    try {
      await _channel.invokeMethod<void>('launch', {'link': link});
      return;
    } on MissingPluginException {
      // 非鸿蒙平台没有自定义通道时，继续使用 url_launcher。
    }

    final uri = Uri.parse(link);
    await launchUrl(uri);
  }

  static Future<void> launchEmail({
    required String recipient,
    required String subject,
    required String body,
  }) async {
    await _channel.invokeMethod<void>('launchEmail', {
      'recipient': recipient.trim(),
      'subject': subject.trim(),
      'body': body,
    });
  }
}
