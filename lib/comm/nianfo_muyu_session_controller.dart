/// 十念法正式播放会话控制器（对应 Swift 原版 NianFoMuyuSessionController.swift）
///
/// 状态机：idle → leadingChime → playing → completed
///                         └──────→ idle（用户停止/离开）
///
/// 关键设计：
/// - 引磬延迟用可等待的 await + 状态校验实现，退出/停止后不会回放（消除竞态）。
/// - 用独立 [strikeIndex] 推导十声位置，不绑定剩余次数（非 10 倍数时首声仍为第 1 声）。
/// - 开始时取得模式值类型快照，每拍只读取快照，不查持久化。
/// - 完成一轮通过 [onCompleted] 回调交页面写回 isComplete。

import 'dart:async';

import 'package:gongke/comm/audio_tools.dart';
import 'package:gongke/comm/muyu_rhythm_audio_player.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

enum NianFoMuyuState {
  idle,
  leadingChime,
  playing,
  completed,
}

class NianFoMuyuSessionController {
  NianFoMuyuState _state = NianFoMuyuState.idle;
  NianFoMuyuState get state => _state;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int remainingCount = 0;

  /// 已播放声数（用于 UI 展示：当前第 N 声）。
  int get playedCount => _totalCount - remainingCount;

  MuyuRhythmPattern? activePattern;

  /// 独立声位索引（0 基），每实际播放成功 +1，按模式长度循环。
  int strikeIndex = 0;

  final MuyuRhythmAudioPlayer _audio = MuyuRhythmAudioPlayer();
  Timer? _beatTimer;
  Duration _interval = const Duration(seconds: 1);

  /// 完成一轮后回调（由页面写回 isComplete）。
  final void Function()? onCompleted;

  NianFoMuyuSessionController({this.onCompleted});

  bool get isActive =>
      _state == NianFoMuyuState.playing ||
      _state == NianFoMuyuState.leadingChime;

  /// 全新开始：剩余次数重置为 totalCount，声位归零。
  Future<void> start({
    required MuyuRhythmPattern pattern,
    required int totalCount,
    required Duration interval,
  }) async {
    if (isActive) return;
    if (totalCount <= 0) return;
    activePattern = pattern;
    _totalCount = totalCount;
    remainingCount = totalCount;
    strikeIndex = 0;
    _interval = interval;
    _state = NianFoMuyuState.leadingChime;

    await AudioTools.playLocalAssetAndWait('mp3/yinqing.wav');
    // 等待引磬期间若被停止/销毁，不进入 playing（消除竞态）。
    if (_state != NianFoMuyuState.leadingChime) return;

    _state = NianFoMuyuState.playing;
    _beatTimer = Timer.periodic(_interval, (_) => _onBeat());
  }

  /// 暂停后继续：保留剩余次数，声位归零。
  Future<void> resume({
    required MuyuRhythmPattern pattern,
    required Duration interval,
  }) async {
    if (isActive) return;
    if (remainingCount <= 0) return;
    activePattern = pattern;
    _interval = interval;
    strikeIndex = 0;
    _state = NianFoMuyuState.leadingChime;

    await AudioTools.playLocalAssetAndWait('mp3/yinqing.wav');
    if (_state != NianFoMuyuState.leadingChime) return;

    _state = NianFoMuyuState.playing;
    _beatTimer = Timer.periodic(_interval, (_) => _onBeat());
  }

  void _onBeat() {
    if (_state != NianFoMuyuState.playing) return;
    if (remainingCount <= 0) {
      _complete();
      return;
    }
    final variant = activePattern?.variantForZeroBasedStrikeIndex(strikeIndex) ??
        MuyuSoundVariant.regular;
    _audio.playMuyu(variant);
    strikeIndex++;
    remainingCount--;
    if (remainingCount <= 0) {
      _complete();
    }
  }

  void _complete() {
    _beatTimer?.cancel();
    _beatTimer = null;
    _audio.stopMuyu();
    _state = NianFoMuyuState.completed;
    // 完成引磬（与 Swift 一致：先停木鱼再敲结束引磬）。
    AudioTools.playLocalAsset('mp3/yinqing.wav');
    onCompleted?.call();
  }

  /// 用户停止 / 离开页面：取消定时器、停止音频、声位归零、回到 idle。
  /// 保留 remainingCount（再次开始时用 resume）。
  void pause() {
    _beatTimer?.cancel();
    _beatTimer = null;
    _audio.stopMuyu();
    strikeIndex = 0;
    if (_state != NianFoMuyuState.completed) {
      _state = NianFoMuyuState.idle;
    }
  }

  /// 彻底清理（页面 dispose 时）。
  void dispose() {
    _beatTimer?.cancel();
    _beatTimer = null;
    _audio.stopMuyu();
    strikeIndex = 0;
    _state = NianFoMuyuState.idle;
  }
}
