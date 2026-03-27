import 'dart:async';
import 'package:flutter/material.dart';

class TtsTools {
  TtsTools();

  Future<void> speak(String text, VoidCallback? onDone) async {
    if (onDone != null) {
      scheduleMicrotask(onDone);
    }
  }

  Future<void> stop() async {
    return;
  }

  Future<void> pause() async {
    return;
  }
}
