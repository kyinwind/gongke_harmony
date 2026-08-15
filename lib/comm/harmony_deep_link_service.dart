import 'package:flutter/services.dart';

class HarmonyDeepLinkService {
  HarmonyDeepLinkService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('gongke/deep_link');

  final MethodChannel _channel;

  Future<void> initialize(
      Future<void> Function(Map<String, dynamic>) onLink) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        await onLink(_map(call.arguments));
      }
    });
    final initial =
        await _channel.invokeMapMethod<String, dynamic>('getInitialDeepLink');
    if (initial != null && initial.isNotEmpty) await onLink(initial);
  }

  Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from((value as Map?) ?? const {});
}
