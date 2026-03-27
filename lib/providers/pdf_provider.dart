import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

// PDF 控制器
final pdfControllerProvider = StateProvider<PdfController?>((ref) => null);
final pdfLoadingDoneProvider = StateProvider<bool>((ref) => false); //pdf加载状态
final pdfThumbnailDoneProvider = StateProvider<bool>(
  (ref) => false,
); //pdf缩略图提取完成状态

class PageCache {
  final int pageIndex; // 页码（从 1 开始）
  PdfPageImage? image; // 页面的图像
  PdfPageImage? thumbnail;

  PageCache({
    required this.pageIndex,
    required this.image,
    required this.thumbnail,
  });
}
