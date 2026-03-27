import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioTools {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isDisposed = false;
  static VoidCallback? _onCompleteCallback;
  static StreamSubscription<void>? _playerCompleteSubscription;

  static Future<void> playLocalAsset(
    String file, { // 音频文件名
    VoidCallback? onComplete, // 播放完成回调
    double? playbackRate, // 播放速率，默认1.0
  }) async {
    if (_isDisposed) {
      await _player.dispose();
      _isDisposed = false;
    }

    // 正确取消之前的监听
    await _playerCompleteSubscription?.cancel();

    if (onComplete != null) {
      _onCompleteCallback = onComplete;
      _playerCompleteSubscription = _player.onPlayerComplete.listen((event) {
        debugPrint('音频播放完成');
        _onCompleteCallback?.call();
      });
    }

    try {
      await _player.stop();
      if (playbackRate != null) {
        _player.setPlaybackRate(playbackRate);
      }
      await _player.play(AssetSource(file));
    } catch (e) {
      debugPrint('音频播放出错: $e');
    }
  }

  static Future<void> stop() async {
    if (!_isDisposed) {
      await _player.stop();
    }
  }

  static Future<void> clearAndStop() async {
    if (!_isDisposed) {
      _onCompleteCallback = null;
      await _playerCompleteSubscription?.cancel();
      await _player.stop();
    }
  }

  static Future<void> dispose() async {
    if (!_isDisposed) {
      await _playerCompleteSubscription?.cancel();
      await _player.dispose();
      _isDisposed = true;
    }
  }
}
