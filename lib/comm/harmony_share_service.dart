import 'package:flutter/services.dart';

class HarmonyShareService {
  const HarmonyShareService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('gongke/share');

  final MethodChannel _channel;

  Future<void> shareText({required String title, required String text}) async {
    final content = text.trim();
    if (content.isEmpty) {
      throw const FormatException('分享内容不能为空');
    }
    await _channel.invokeMethod<void>('shareText', {
      'title': title.trim(),
      'text': content,
    });
  }

  Future<void> shareJson({required String title, required String json}) async {
    final content = json.trim();
    if (content.isEmpty) {
      throw const FormatException('JSON 内容不能为空');
    }
    await _channel.invokeMethod<void>('shareJson', {
      'title': title.trim(),
      'json': content,
    });
  }

  Future<void> shareFile({
    required String title,
    required String path,
    required String utd,
  }) async {
    if (path.trim().isEmpty) throw const FormatException('分享文件路径不能为空');
    await _channel.invokeMethod<void>('shareFile', {
      'title': title.trim(),
      'path': path,
      'utd': utd,
    });
  }
}
