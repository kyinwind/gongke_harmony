import 'dart:async';
import 'package:flutter/services.dart';

class TtsTools {
  TtsTools() {
    _ensureHandler();
  }

  static const MethodChannel _channel = MethodChannel('gongke/tts');
  static bool _handlerRegistered = false;
  static String? _activeRequestId;
  static VoidCallback? _pendingOnDone;
  static List<String> _pendingChunks = const [];
  static int _nextChunkIndex = 0;

  static const int maxChunkLength = 500;

  static List<String> splitText(String text, {int limit = maxChunkLength}) {
    final normalized = text.trim();
    if (normalized.isEmpty) return const [];
    if (limit <= 0) throw ArgumentError.value(limit, 'limit', '必须大于 0');

    final chunks = <String>[];
    var remaining = normalized;
    while (remaining.length > limit) {
      var splitAt = -1;
      const separators = '。！？；，\n.!?;,';
      for (var index = limit; index > 0; index--) {
        if (separators.contains(remaining[index - 1])) {
          splitAt = index;
          break;
        }
      }
      if (splitAt <= 0) splitAt = limit;
      chunks.add(remaining.substring(0, splitAt).trim());
      remaining = remaining.substring(splitAt).trimLeft();
    }
    if (remaining.isNotEmpty) chunks.add(remaining);
    return chunks;
  }

  static void _finishRequest() {
    final callback = _pendingOnDone;
    _pendingChunks = const [];
    _nextChunkIndex = 0;
    _pendingOnDone = null;
    _activeRequestId = null;
    callback?.call();
  }

  static Future<void> _speakNextChunk() async {
    if (_nextChunkIndex >= _pendingChunks.length) {
      _finishRequest();
      return;
    }
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeRequestId = requestId;
    final chunk = _pendingChunks[_nextChunkIndex++];
    await _channel.invokeMethod('speak', {
      'text': chunk,
      'requestId': requestId,
      'rate': 0.9,
      'pitch': 1.0,
    });
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    final args = (call.arguments as Map?)?.cast<Object?, Object?>();
    final requestId = args?['requestId']?.toString();
    if (requestId == null || requestId != _activeRequestId) {
      return;
    }

    switch (call.method) {
      case 'onStop':
      case 'onError':
        _finishRequest();
        break;
      case 'onComplete':
        _activeRequestId = null;
        await _speakNextChunk();
        break;
      case 'onStart':
      default:
        break;
    }
  }

  static void _ensureHandler() {
    if (_handlerRegistered) {
      return;
    }
    _channel.setMethodCallHandler(_handleMethodCall);
    _handlerRegistered = true;
  }

  Future<void> speak(String text, VoidCallback? onDone) async {
    _ensureHandler();
    final normalized = text.trim();
    if (normalized.isEmpty) {
      onDone?.call();
      return;
    }

    if (_activeRequestId != null) {
      await stop();
    }

    _pendingChunks = splitText(normalized);
    _nextChunkIndex = 0;
    _pendingOnDone = onDone;
    await _speakNextChunk();
  }

  Future<void> stop() async {
    _pendingOnDone = null;
    _activeRequestId = null;
    _pendingChunks = const [];
    _nextChunkIndex = 0;
    await _channel.invokeMethod('stop');
  }

  Future<void> pause() async {
    await stop();
  }
}
