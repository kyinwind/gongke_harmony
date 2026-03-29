/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdfview_ohos/flutter_pdfview_ohos.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPDFViewController
    with MockPlatformInterfaceMixin
    implements PDFViewController {
  @override
  Future<int?> getCurrentPage() async {
    return 10;
  }

  @override
  Future<int?> getPageCount() async {
    return 20;
  }

  @override
  Future<bool?> setPage(int page) async {
    return true;
  }
}

void main() {
  MockPDFViewController controller = MockPDFViewController();

  test('getCurrentPage', () async {
    expect(await controller.getCurrentPage(), 10);
  });

  test('getPageCount', () async {
    expect(await controller.getPageCount(), 20);
  });

  test('setPage', () async {
    expect(await controller.setPage(10), true);
  });
}