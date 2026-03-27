import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:pdfium_bindings/pdfium_bindings.dart';

// 表示一页的内容
class WinPDFPage {
  final int index;
  final String text;
  WinPDFPage(this.index, this.text);
}

// 表示整个 PDF 文档
class WinPDFDoc {
  final File file;
  final List<WinPDFPage> pages;
  int get pageCount => pages.length;
  WinPDFDoc(this.file, this.pages);
}

// 动态库扩展：绑定文本提取相关函数
extension PdfiumTextExtraction on DynamicLibrary {
  Pointer<Void> FPDFText_LoadPage(Pointer<Void> page) =>
      lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)
      >('FPDFText_LoadPage')(page);

  void FPDFText_ClosePage(Pointer<Void> textPage) =>
      lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('FPDFText_ClosePage')(textPage);

  int FPDFText_CountChars(Pointer<Void> textPage) =>
      lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('FPDFText_CountChars')(textPage);

  int FPDFText_GetText(
    Pointer<Void> textPage,
    int startIndex,
    int count,
    Pointer<Uint16> result,
  ) =>
      lookupFunction<
        Int32 Function(Pointer<Void>, Int32, Int32, Pointer<Uint16>),
        int Function(Pointer<Void>, int, int, Pointer<Uint16>)
      >('FPDFText_GetText')(textPage, startIndex, count, result);
}

// 提取 PDF 文本
Future<WinPDFDoc> loadPdfAndExtractText(String filePath) async {
  //final libraryPath = path.join(Directory.current.path, 'pdfium.dll');
  //print('------------------------loadPdfAndExtractText');
  final dylib = DynamicLibrary.open(
    'pdfium_all.dll',
  ); //不用自己拼路径，而是让系统自己去找，当前目录和系统目录
  final pdfium = PDFiumBindings(dylib);
  final callocator = calloc;

  final config = callocator<FPDF_LIBRARY_CONFIG>();
  final filePathPtr = filePath.toNativeUtf8();
  Pointer<fpdf_document_t__>? doc;
  File file = File(filePath);
  try {
    config.ref
      ..version = 2
      ..m_pUserFontPaths = nullptr
      ..m_pIsolate = nullptr
      ..m_v8EmbedderSlot = 0;

    pdfium.FPDF_InitLibraryWithConfig(config);

    doc = pdfium.FPDF_LoadDocument(filePathPtr.cast(), nullptr);
    if (doc == nullptr) {
      final err = pdfium.FPDF_GetLastError();
      throw Exception('打开 PDF 失败，错误码: $err');
    }

    final pageCount = pdfium.FPDF_GetPageCount(doc.cast());
    final pages = <WinPDFPage>[];

    for (int i = 0; i < pageCount; i++) {
      final page = pdfium.FPDF_LoadPage(doc.cast(), i);
      if (page == nullptr) continue;

      final textPage = dylib.FPDFText_LoadPage(page.cast<Void>());
      if (textPage == nullptr) {
        pdfium.FPDF_ClosePage(page.cast());
        continue;
      }

      try {
        final charCount = dylib.FPDFText_CountChars(textPage);
        String text = '';
        if (charCount > 0) {
          final buffer = callocator<Uint16>(charCount + 1);
          try {
            final copied = dylib.FPDFText_GetText(
              textPage,
              0,
              charCount,
              buffer,
            );
            text = String.fromCharCodes(buffer.asTypedList(copied));
          } finally {
            callocator.free(buffer);
          }
        }
        pages.add(WinPDFPage(i, text));
      } finally {
        dylib.FPDFText_ClosePage(textPage);
        pdfium.FPDF_ClosePage(page.cast());
      }
    }
    //print('------------------------loadPdfAndExtractText----------结束');
    return WinPDFDoc(file, pages);
  } finally {
    if (doc != null) pdfium.FPDF_CloseDocument(doc.cast());
    callocator.free(filePathPtr);
    pdfium.FPDF_DestroyLibrary();
    callocator.free(config);
  }
}
