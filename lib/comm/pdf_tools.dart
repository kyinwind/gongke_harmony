import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:pdf_render_ohos/pdf_render.dart';
import 'package:pdf_render_ohos/pdf_render_widgets.dart';

class AppPdfTools {
  const AppPdfTools._();

  static Future<PdfDocument> openDocument(JingShuData jingshu) {
    if (jingshu.type == 'shanshu' || jingshu.type == 'jingshu') {
      return PdfDocument.openAsset('assets/pdfs/${jingshu.fileUrl}');
    }
    return PdfDocument.openFile(jingshu.fileUrl);
  }

  static Widget buildPageViewer({
    required JingShuData jingshu,
    required int pageNumber,
    required void Function(dynamic error) onError,
  }) {
    final viewerKey = ValueKey('${jingshu.id}:$pageNumber');
    final child = (jingshu.type == 'shanshu' || jingshu.type == 'jingshu')
        ? PdfDocumentLoader.openAsset(
            'assets/pdfs/${jingshu.fileUrl}',
            key: viewerKey,
            pageNumber: pageNumber,
            onError: onError,
          )
        : PdfDocumentLoader.openFile(
            jingshu.fileUrl,
            key: viewerKey,
            pageNumber: pageNumber,
            onError: onError,
          );

    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: child,
    );
  }
}
