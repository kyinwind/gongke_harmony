import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // 获取 kReleaseMode

// 初始化日志工具
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
  ),
  level: kReleaseMode ? Level.nothing : Level.debug,
);
