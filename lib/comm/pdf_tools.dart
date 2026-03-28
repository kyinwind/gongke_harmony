import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview_ohos/flutter_pdfview_ohos.dart';
import 'package:gongke/database.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppPdfViewerController {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  Future<void> attach(PDFViewController controller) async {
    if (_controller.isCompleted) {
      return;
    }
    _controller.complete(controller);
  }

  Future<PDFViewController?> get ready async {
    if (!_controller.isCompleted) {
      return null;
    }
    return _controller.future;
  }

  Future<void> goToPage(int pageNumber) async {
    final controller = await ready;
    if (controller == null) {
      return;
    }
    await controller.setPage(pageNumber);
  }
}

class AppPdfTools {
  const AppPdfTools._();

  static Future<String> resolveFilePath(JingShuData jingshu) async {
    if (jingshu.type == 'shanshu' || jingshu.type == 'jingshu') {
      final docsDir = await getApplicationDocumentsDirectory();
      final assetName = path.basename(jingshu.fileUrl);
      final targetDir = Directory(path.join(docsDir.path, 'bundled_pdfs'));
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final targetPath = path.join(targetDir.path, assetName);
      final targetFile = File(targetPath);
      if (!targetFile.existsSync()) {
        final data = await rootBundle.load('assets/pdfs/${jingshu.fileUrl}');
        await targetFile.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      }
      return targetPath;
    }
    return jingshu.fileUrl;
  }

  static Widget buildViewer({
    required String filePath,
    required AppPdfViewerController controller,
    required int initialPage,
    required void Function(PDFViewController controller) onViewCreated,
    required void Function(PDFViewController controller, int? pageCount)
    onRender,
    required void Function(int? page, int? pageCount) onPageChanged,
    required void Function(dynamic error) onError,
  }) {
    return PDFView(
      key: ValueKey(filePath),
      filePath: filePath,
      enableSwipe: false,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: false,
      pageSnap: true,
      defaultPage: initialPage,
      fitPolicy: FitPolicy.HEIGHT,
      onViewCreated: (pdfController) async {
        await controller.attach(pdfController);
        onViewCreated(pdfController);
      },
      onRender: (pages) async {
        final pdfController = await controller.ready;
        if (pdfController == null) {
          return;
        }
        onRender(pdfController, pages);
      },
      onPageChanged: onPageChanged,
      onError: onError,
      onPageError: (page, error) {
        onError('Page $page: $error');
      },
    );
  }
}
