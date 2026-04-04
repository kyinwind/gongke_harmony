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

  static Future<void> _handleMethodCall(MethodCall call) async {
    final args = (call.arguments as Map?)?.cast<Object?, Object?>();
    final requestId = args?['requestId']?.toString();
    if (requestId == null || requestId != _activeRequestId) {
      return;
    }

    switch (call.method) {
      case 'onStop':
      case 'onError':
        _pendingOnDone = null;
        _activeRequestId = null;
        break;
      case 'onComplete':
        final callback = _pendingOnDone;
        _pendingOnDone = null;
        _activeRequestId = null;
        callback?.call();
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

    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeRequestId = requestId;
    _pendingOnDone = onDone;

    await _channel.invokeMethod('speak', {
      'text': normalized,
      'requestId': requestId,
      'rate': 0.9,
      'pitch': 1.0,
    });
  }

  Future<void> stop() async {
    _pendingOnDone = null;
    _activeRequestId = null;
    await _channel.invokeMethod('stop');
  }

  Future<void> pause() async {
    await stop();
  }
}
