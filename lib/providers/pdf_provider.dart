import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final pdfLoadingDoneProvider = StateProvider<bool>((ref) => false); //pdf加载状态
final pdfThumbnailDoneProvider = StateProvider<bool>(
  (ref) => false,
); //pdf缩略图提取完成状态

class PageCache {
  final int pageIndex; // 页码（从 1 开始）
  ui.Image? image; // 页面的图像
  ui.Image? thumbnail;

  PageCache({
    required this.pageIndex,
    required this.image,
    required this.thumbnail,
  });
}
