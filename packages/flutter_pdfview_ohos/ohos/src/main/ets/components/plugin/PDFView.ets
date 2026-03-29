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
 
import { pdfService, pdfViewManager, PdfView } from '@kit.PDFKit';
import { fileIo } from '@kit.CoreFileKit';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { common } from '@kit.AbilityKit';
import { FlutterPDFView } from './FlutterPDFView'

@Component
export struct PDFView {
  @Prop params: Params;
  flutterPDFView: FlutterPDFView = this.params.platformView as FlutterPDFView
  //总页数
  @StorageLink('totalPage') totalPage: number = 0;
  //当前页
  @StorageLink('currentPage') currentPage: number = 0;
  //跳转页
  @State scrollerPageIndex: number = 0;
  //默认显示页
  @State defaultPage: number = 0;
  @State enableSwipe: boolean = true;
  @State swipeHorizontal: boolean = false;
  @State autoSpacing: boolean = true;
  @State fitPolicy: string = "FitPolicy.WIDTH";
  @State pageFitPolicy: number = 2;
  @State preventLinkNavigation: boolean = false;
  filePath: string = '';
  password: string = '';
  private controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();

  getPageFitPolicy() {
    if (this.fitPolicy == "FitPolicy.WIDTH") {
      this.pageFitPolicy = pdfService.PageFit.FIT_WIDTH;
    } else if (this.fitPolicy == "FitPolicy.HEIGHT") {
      this.pageFitPolicy = pdfService.PageFit.FIT_HEIGHT;
    } else if (this.fitPolicy == "FitPolicy.BOTH") {
      this.pageFitPolicy = pdfService.PageFit.FIT_PAGE;
    }
  }

  aboutToAppear() {
    this.filePath = this.flutterPDFView.getFilePath();
    this.password = this.flutterPDFView.getPassword();
    this.defaultPage = this.flutterPDFView.getDefaultPage();
    this.enableSwipe = this.flutterPDFView.getEnableSwipe();
    this.swipeHorizontal = this.flutterPDFView.getSwipeHorizontal();
    this.autoSpacing = this.flutterPDFView.getAutoSpacing();
    this.fitPolicy = this.flutterPDFView.getFitPolicy();
    this.preventLinkNavigation = this.flutterPDFView.getPreventLinkNavigation();

    this.getPageFitPolicy();

    let context = getContext() as common.UIAbilityContext;
    context.eventHub.on('setPage', (index: number) => {
      this.controller.goToPage(index);
    });

    context.eventHub.on('setSwipeEnabled', (value: boolean) => {
      this.enableSwipe = value;
    });

    context.eventHub.on('setPreventLinkNavigation', (value: boolean) => {
      this.preventLinkNavigation = value;
    });

    (async () => {
      this.controller.registerPageCountChangedListener((pageCount: number) => {
        this.totalPage = pageCount;
        AppStorage.setOrCreate('totalPage', this.totalPage);
      });

      let loadResult: pdfService.ParseResult =
        await this.controller.loadDocument(this.filePath, this.password, this.defaultPage);

      if (pdfService.ParseResult.PARSE_SUCCESS === loadResult) {
        this.flutterPDFView.onRender(this.totalPage);
        if (this.autoSpacing) {
          this.controller.setPageSpacing(0, 36);
        } else {
          this.controller.setPageSpacing(0, 0);
        }
      } else {
        this.flutterPDFView.onError({ name: 'loadDocument', message: Object.keys(pdfService.ParseResult)[loadResult] });
      }

      try {
        this.controller.registerPageChangedListener((pageIndex: number) => {
          this.currentPage = pageIndex;
          AppStorage.setOrCreate('currentPage', this.currentPage);
          this.flutterPDFView.onPageChanged(this.currentPage, this.totalPage);
        })
      } catch (err) {
        this.flutterPDFView.onPageError(this.currentPage, err);
      }

      if (!this.preventLinkNavigation) {
        this.controller.registerActionClickListener((redirectInfo: pdfViewManager.RedirectInfo) => {
          this.flutterPDFView.onLinkHandler(redirectInfo.content);
        });
      }
    })()
  }

  // 释放PDF文档
  aboutToDisappear() {
    this.controller.releaseDocument()
  }

  build() {
    Row() {
      PdfView({
        controller: this.controller,
        pageFit: this.pageFitPolicy,
        showScroll: false
      })
        .enabled(this.enableSwipe)
        .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function PdfBuilder(params: Params) {
  PDFView({ params: params });
}
