import 'package:audioplayers/audioplayers.dart';

class AudioTools {
  static AudioPlayer? _player;
  static void Function()? _onComplete;

  static AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) {
      return existing;
    }

    final player = AudioPlayer(playerId: 'gongke_audio');
    player.onPlayerComplete.listen((_) {
      final callback = _onComplete;
      _onComplete = null;
      callback?.call();
    });
    _player = player;
    return player;
  }

  static Future<void> playLocalAsset(
    String file, {
    void Function()? onComplete,
    double? playbackRate,
  }) async {
    final player = _ensurePlayer();
    _onComplete = onComplete;
    await player.stop();
    if (playbackRate != null) {
      await player.setPlaybackRate(playbackRate);
    } else {
      await player.setPlaybackRate(1.0);
    }
    await player.play(AssetSource(file));
  }

  static Future<void> stop() async {
    _onComplete = null;
    final player = _player;
    if (player == null) {
      return;
    }
    await player.stop();
  }

  static Future<void> clearAndStop() async {
    await stop();
  }

  static Future<void> dispose() async {
    _onComplete = null;
    final player = _player;
    _player = null;
    if (player == null) {
      return;
    }
    await player.dispose();
  }
}
