import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLauncherTools {
  static const MethodChannel _channel =
      MethodChannel('gongke/external_launcher');

  static Future<void> launch(String link) async {
    try {
      await _channel.invokeMethod<void>('launch', {'link': link});
      return;
    } catch (_) {}

    final uri = Uri.parse(link);
    await launchUrl(uri);
  }
}
