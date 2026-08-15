/// 十念法独立音频服务（对应 Swift 原版 MuyuRhythmAudioPlayer.swift）
///
/// 维护普通 / A / B / C 四个独立 AudioPlayer，用于：
/// 1. 播放某音色前停止其他木鱼播放器，避免不同音高重叠（互斥重播）；
/// 2. 资源缺失时按 C→B→A→普通 等规则降级；
/// 3. 统一停止全部木鱼。
///
/// 引磬（yinqing）仍由现有 AudioTools 负责，本服务不改其职责。

import 'package:audioplayers/audioplayers.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

class MuyuRhythmAudioPlayer {
  MuyuRhythmAudioPlayer._();

  static final MuyuRhythmAudioPlayer _instance = MuyuRhythmAudioPlayer._();
  factory MuyuRhythmAudioPlayer() => _instance;

  final Map<MuyuSoundVariant, AudioPlayer> _players = {};

  AudioPlayer _playerFor(MuyuSoundVariant v) {
    return _players.putIfAbsent(
      v,
      () => AudioPlayer(playerId: 'muyu_rhythm_${v.name}'),
    );
  }

  /// 降级链：C→B→A→普通；B→A→普通；A→普通；普通→普通。
  static List<MuyuSoundVariant> _degradeChain(MuyuSoundVariant v) {
    switch (v) {
      case MuyuSoundVariant.c:
        return const [
          MuyuSoundVariant.c,
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular
        ];
      case MuyuSoundVariant.b:
        return const [
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular
        ];
      case MuyuSoundVariant.a:
        return const [MuyuSoundVariant.a, MuyuSoundVariant.regular];
      case MuyuSoundVariant.regular:
        return const [MuyuSoundVariant.regular];
    }
  }

  /// 播放某音色的木鱼声。先停止其他音色的播放器（互斥），缺失则降级。
  Future<void> playMuyu(MuyuSoundVariant variant) async {
    for (final other in MuyuSoundVariant.values) {
      if (other != variant) {
        try {
          await _playerFor(other).stop();
        } catch (_) {}
      }
    }
    for (final v in _degradeChain(variant)) {
      try {
        final player = _playerFor(v);
        await player.stop();
        await player.play(AssetSource(v.asset));
        return;
      } catch (_) {
        // 该音色加载/播放失败，尝试降级链下一个
        continue;
      }
    }
  }

  /// 停止并归零全部木鱼播放器。
  Future<void> stopMuyu() async {
    for (final player in _players.values) {
      try {
        await player.stop();
      } catch (_) {}
    }
  }

  /// 释放所有播放器（应用退出时调用）。
  Future<void> dispose() async {
    for (final player in _players.values) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}
