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

import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { pdfService } from '@kit.PDFKit';
import { PdfBuilder } from './PDFView';

@Observed
export class FlutterPDFView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;
  pageIndex: number = 0;
  context: common.UIAbilityContext;
  filePath: string;
  password: string;
  document: pdfService.PdfDocument = new pdfService.PdfDocument();
  isDocumentLoaded: boolean = false;
  defaultPage: number;
  enableSwipe: boolean;
  swipeHorizontal: boolean;
  autoSpacing: boolean;
  fitPolicy: string;
  preventLinkNavigation: boolean;

  constructor(context: common.UIAbilityContext, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    let params = args as Map<String, Object>;
    this.filePath = params.get("filePath") as string;
    this.password = params.get("password") as string;
    this.defaultPage = params.get("defaultPage") as number;
    this.enableSwipe = params.get("enableSwipe") as boolean;
    this.swipeHorizontal = params.get("swipeHorizontal") as boolean;
    this.autoSpacing = params.get("autoSpacing") as boolean;
    this.fitPolicy = params.get("fitPolicy") as string;
    this.preventLinkNavigation = params.get("preventLinkNavigation") as boolean;

    this.context = context;
    this.methodChannel =
      new MethodChannel(message, `plugins.endigo.io/pdfview_${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "pageCount":
        this.getPageCount(result);
        break;
      case "currentPage":
        this.getCurrentPage(result);
        break;
      case "setPage":
        this.setPage(call, result);
        break;
      case "getPageText":
        this.getPageText(call, result);
        break;
      case "updateSettings":
        this.updateSettings(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  public getPageCount(result: MethodResult) {
    result.success(AppStorage.get('totalPage'));
  }

  public getCurrentPage(result: MethodResult) {
    result.success(AppStorage.get('currentPage'));
  }

  public setPage(call: MethodCall, result: MethodResult) {
    if (call.argument("page") != null) {
      this.pageIndex = call.argument("page");
      this.context?.eventHub.emit('setPage', this.pageIndex);
    }
    result.success(true);
  }

  public getPageText(call: MethodCall, result: MethodResult) {
    try {
      this.ensureDocumentLoaded();
      let pageNumber = call.argument("page") as number;
      if (pageNumber < 0 || pageNumber >= this.document.getPageCount()) {
        result.success('');
        return;
      }

      let page: pdfService.PdfPage = this.document.getPage(pageNumber);
      let objects: Array<pdfService.GraphicsObject> = page.getGraphicsObjects();
      let texts: Array<string> = [];
      for (let i = 0; i < objects.length; i++) {
        let object = objects[i];
        if (object.type === pdfService.GraphicsObjectType.OBJECT_TEXT) {
          let textObject = object as pdfService.TextObject;
          let text = textObject.text;
          if (text && text.trim().length > 0) {
            texts.push(text.trim());
          }
        }
      }
      page.release();
      result.success(texts.join('\n'));
    } catch (err) {
      result.error('getPageText', JSON.stringify(err), null);
    }
  }

  private ensureDocumentLoaded() {
    if (this.isDocumentLoaded) {
      return;
    }
    let loadResult = this.document.loadDocument(this.filePath, this.password);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      throw new Error(`loadDocument failed: ${loadResult}`);
    }
    this.isDocumentLoaded = true;
  }

  private updateSettings(methodCall: MethodCall, result: MethodResult) {
    this.applySettings(methodCall.args);
    result.success(null);
  }

  private applySettings(settings: Map<String, Object>) {
    for (let key of settings.keys()) {
      switch (key) {
        case "enableSwipe":
          this.context?.eventHub.emit('setSwipeEnabled', settings.get(key));
          break;
        case "preventLinkNavigation":
          this.context?.eventHub.emit('setPreventLinkNavigation', settings.get(key));
          break;
        default:
          throw new RangeError("Unknown PDFView setting: " + key);
      }
    }
  }

  public onPageChanged(page: number, total: number) {
    let args: Map<String, Object> = new Map();
    args.set("page", page);
    args.set("total", total);
    this.methodChannel.invokeMethod("onPageChanged", args);
  }

  public onError(t: Error) {
    let args: Map<String, Object> = new Map();
    args.set("error", JSON.stringify(t));
    this.methodChannel.invokeMethod("onError", args);
  }

  public onPageError(page: number, t: Error) {
    let args: Map<String, Object> = new Map();
    args.set("page", page);
    args.set("error", JSON.stringify(t));
    this.methodChannel.invokeMethod("onPageError", args);
  }

  public onRender(pages: number) {
    let args: Map<String, Object> = new Map();
    args.set("pages", pages);
    this.methodChannel.invokeMethod("onRender", args);
  }

  public onLinkHandler(uri: string) {
    this.methodChannel.invokeMethod("onLinkHandler", uri);
  }

  public getFilePath() {
    return this.filePath;
  }

  public getPassword() {
    return this.password;
  }

  public getDefaultPage() {
    return this.defaultPage;
  }

  public getEnableSwipe() {
    return this.enableSwipe;
  }

  public getSwipeHorizontal() {
    return this.swipeHorizontal;
  }

  public getAutoSpacing() {
    return this.autoSpacing;
  }

  public getFitPolicy() {
    return this.fitPolicy;
  }

  public getPreventLinkNavigation() {
    return this.preventLinkNavigation;
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(PdfBuilder);
  }

  dispose(): void {
    if (this.isDocumentLoaded) {
      this.document.releaseDocument();
      this.isDocumentLoaded = false;
    }
    this.context.eventHub.off('setPage');
    this.context.eventHub.off('setSwipeEnabled');
    this.context.eventHub.off('setPreventLinkNavigation');
    this.methodChannel.setMethodCallHandler(null);
  }
}
