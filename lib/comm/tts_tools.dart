import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

//enum TtsState { playing, stopped, paused, continued }

class TtsTools {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  // 构造函数
  TtsTools() {
    // 这里写初始化代码，创建实例时会自动执行
    print("TtsTools 开始初始化...");
    // 示例：初始化TTS引擎
    flutterTts = FlutterTts();
    flutterTts.setLanguage("zh-CN");
    flutterTts.setSpeechRate(0.5); // 设置语速
    flutterTts.setPitch(1.0); // 设置音调
    //设置播放完再播放下一个
    _setAwaitOptions();
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
    print("TtsTools 初始化完成");
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> speak(String text, VoidCallback? onDone) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.speak(text);
    if (onDone != null) {
      flutterTts.setCompletionHandler(() {
        onDone();
      });
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> stop() async {
    flutterTts.setCompletionHandler(() {});
    var result = await flutterTts.stop();
    if (result == 1) {}
  }

  Future<void> pause() async {
    var result = await flutterTts.pause();
    if (result == 1) {}
  }
}
