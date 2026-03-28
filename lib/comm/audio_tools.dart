class AudioTools {
  static Future<void> playLocalAsset(
    String file, {
    void Function()? onComplete,
    double? playbackRate,
  }) async {
    if (file.isNotEmpty || playbackRate != null) {}
    onComplete?.call();
  }

  static Future<void> stop() async {}

  static Future<void> clearAndStop() async {}

  static Future<void> dispose() async {}
}
