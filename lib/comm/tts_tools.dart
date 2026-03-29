import 'dart:async';
import 'package:flutter/services.dart';

class TtsTools {
  TtsTools() {
    _ensureHandler();
  }

  static const MethodChannel _channel = MethodChannel('gongke/tts');
  static bool _handlerRegistered = false;
  static String? _activeRequestId;
  static Timer? _completionTimer;
  static VoidCallback? _pendingOnDone;

  static Future<void> _handleMethodCall(MethodCall call) async {
    final args = (call.arguments as Map?)?.cast<Object?, Object?>();
    final requestId = args?['requestId']?.toString();
    if (requestId == null || requestId != _activeRequestId) {
      return;
    }

    switch (call.method) {
      case 'onStop':
      case 'onError':
        _completionTimer?.cancel();
        _completionTimer = null;
        _pendingOnDone = null;
        _activeRequestId = null;
        break;
      case 'onComplete':
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

    await stop();

    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeRequestId = requestId;
    _pendingOnDone = onDone;

    final estimatedDuration = _estimateDuration(normalized);
    _completionTimer = Timer(estimatedDuration, () {
      if (_activeRequestId != requestId) {
        return;
      }
      final callback = _pendingOnDone;
      _completionTimer = null;
      _pendingOnDone = null;
      _activeRequestId = null;
      callback?.call();
    });

    await _channel.invokeMethod('speak', {
      'text': normalized,
      'requestId': requestId,
      'rate': 0.9,
      'pitch': 1.0,
    });
  }

  Future<void> stop() async {
    _completionTimer?.cancel();
    _completionTimer = null;
    _pendingOnDone = null;
    _activeRequestId = null;
    await _channel.invokeMethod('stop');
  }

  Future<void> pause() async {
    await stop();
  }

  static Duration _estimateDuration(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    final charCount = normalized.runes.length;
    final punctuationCount =
        RegExp(r'[，。！？；：、,.!?;:\n]').allMatches(text).length;

    const int perCharMs = 260;
    const int perPunctuationMs = 260;
    const int compensationMs = 0;

    final milliseconds = (charCount * perCharMs +
            punctuationCount * perPunctuationMs +
            compensationMs)
        .clamp(3500, 180000);
    return Duration(milliseconds: milliseconds);
  }
}
