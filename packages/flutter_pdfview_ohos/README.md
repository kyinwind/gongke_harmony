# flutter_pdfview_ohos

一个Flutter插件，为OpenHarmony平台提供PDFView组件的实现。

## Usage

```yaml
dependencies:
  flutter_pdfview: any
  flutter_pdfview_ohos: any
```

## Example:

```dart
import 'package:flutter_pdfview_ohos/flutter_pdfview_ohos.dart';

PDFView(
  filePath: widget.path,
  enableSwipe: true,
  swipeHorizontal: true,
  autoSpacing: false,
  pageFling: true,
  pageSnap: true,
  defaultPage: currentPage!,
  fitPolicy: FitPolicy.BOTH,
  preventLinkNavigation:
      false, // if set to true, link navigation will be handled within Flutter
  onRender: (_pages) {
    setState(() {
      pages = _pages;
      isReady = true;
    });
  },
  onError: (error) {
    setState(() {
      errorMessage = error.toString();
    });
    print(error.toString());
  },
  onPageError: (page, error) {
    setState(() {
      errorMessage = '$page: ${error.toString()}';
    });
    print('$page: ${error.toString()}');
  },
  onViewCreated: (PDFViewController pdfViewController) {
    _controller.complete(pdfViewController);
  },
  onLinkHandler: (String? uri) {
    print('goto uri: $uri');
  },
  onPageChanged: (int? page, int? total) {
    print('page change: $page/$total');
    setState(() {
      currentPage = page;
    });
  },
)
```

