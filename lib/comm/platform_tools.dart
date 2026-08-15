class PlatformUtils {
  static bool get isHarmonyOS => true;

  static bool get isMobileLike => true;

  static bool get supportsFileImport => true;

  static bool get supportsImagePick => true;

  static bool get supportsShakeSensor => true;

  static bool get supportsShare => true;

  static bool get supportsTts => true;

  static bool get supportsForegroundService => false;

  static String? get preferredFontFamily => null;

  static double get pdfRenderClarityFactor => 0.75;
}
