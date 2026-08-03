/// 十念法试听控制器（对应 Swift 原版 MuyuRhythmPreviewController.swift）
///
/// 编辑器用于「试听两个完整循环」（20 声）。使用自己的 Timer，不占用页面全局定时器。
/// 草稿变化、停止、页面退出或音频中断时停止并归零。

import 'dart:async';

import 'package:gongke/comm/muyu_rhythm_audio_player.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

class MuyuRhythmPreviewController {
  final MuyuRhythmAudioPlayer _audio = MuyuRhythmAudioPlayer();

  Timer? _timer;
  int _playedCount = 0;
  int _strikeIndex = 0;
  bool isPlaying = false;
  MuyuRhythmPattern? _pattern;
  double _interval = 1.0;

  /// 当前已播放声数（UI 可选展示）。
  int get playedCount => _playedCount;

  /// 开始试听：先停止旧试听并归零，首声立即播放。
  void start({required MuyuRhythmPattern pattern, double interval = 1.0}) {
    stop();
    _pattern = pattern;
    _interval = interval;
    _playedCount = 0;
    _strikeIndex = 0;
    isPlaying = true;
    _playOne();
  }

  void _playOne() {
    if (!isPlaying || _pattern == null) return;
    if (_playedCount >= 20) {
      stop();
      return;
    }
    final variant = _pattern!.variantForZeroBasedStrikeIndex(_strikeIndex);
    _audio.playMuyu(variant);
    _strikeIndex++;
    _playedCount++;
    if (_playedCount >= 20) {
      // 第 20 声播放完后停止
      _timer = Timer(Duration(milliseconds: (_interval * 1000).toInt()), stop);
      return;
    }
    _timer = Timer(Duration(milliseconds: (_interval * 1000).toInt()), _playOne);
  }

  /// 停止试听：停止声音，播放数与索引归零。
  void stop() {
    _timer?.cancel();
    _timer = null;
    isPlaying = false;
    _playedCount = 0;
    _strikeIndex = 0;
    _pattern = null;
    _audio.stopMuyu();
  }

  void dispose() {
    stop();
  }
}
