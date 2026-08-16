/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { BaseOperation } from './BaseOperation';
import { OperationResult } from './OperationResult';

export class MethodCallOperation extends BaseOperation {
  public result: Result;
  private methodCall: MethodCall;

  constructor(methodCall: MethodCall, result: MethodResult) {
    super();
    this.methodCall = methodCall;
    this.result = new Result(result);
  }

  getMethod(): string {
    return this.methodCall.method;
  }

  getArgument<T>(key: string): T {
    return this.methodCall.argument(key);
  }

  hasArgument(key: string): boolean {
    return this.methodCall.hasArgument(key);
  }

  protected getOperationResult(): OperationResult {
    return this.result;
  }
}

class Result implements OperationResult {
  private result: MethodResult;

  constructor(result: MethodResult) {
    this.result = result;
  }

  success(result: Object): void {
    this.result.success(result);
  }

  error(errorCode: string, errorMessage: string, data: Object): void {
    this.result.error(errorCode, errorMessage, data);
  }
}