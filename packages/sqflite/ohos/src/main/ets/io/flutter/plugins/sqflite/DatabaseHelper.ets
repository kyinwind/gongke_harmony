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

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { Tools } from './Tools';
import { BusinessError } from '@ohos.base';
import { Constant } from './OhosConstant';
import deviceInfo from '@ohos.deviceInfo';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import fs from '@ohos.file.fs';

export class DatabaseHelper {
  /// 已加载的数据库
  public static databaseList: Map<string, relationalStore.RdbStore> = new Map<string, relationalStore.RdbStore>();
  /// 加载的数据库的list
  public static databaseIdList: Map<number, string> = new Map<number, string>();
  /// 加载的数据库的list
  private static databaseId: number = 0;

  /// 打开一个数据库（没有则创建）
  public static async openDatabase(context: common.Context, call: MethodCall, result: MethodResult): Promise<number> {
    let id: number = -1;
    let dbPath: string = call.argument(Constant.PARAM_PATH);
    let dbPathNameList: string[] = dbPath.split('/');
    let dbName: string = dbPathNameList[dbPathNameList.length - 1];
    let endWithDb: boolean = Tools.stringEndWith(dbName, '.db');

    if (!endWithDb) {
      dbName = dbName + '.db';
    }

    const isExisted: boolean = await DatabaseHelper.checkDatabaseExisted(dbPath);
    if (isExisted) {
      // 从已有的数据库里面获取
      let local: relationalStore.RdbStore | null = DatabaseHelper.getOnlyLocal(dbName);
      if (local != null) {
        DatabaseHelper.databaseIdList.forEach((value, key) => {
          if (dbName == value) {
            id = key
          }
        })
        let map: Record<string, Object> = {
          'id': id,
          'recovered': false,
          'recoveredInTransaction': false,
        }
        result.success(map);
        return id;
      }
    }

    // 自定义数据库路径
    let customDir: string = '';
    for (let index = 5; index < dbPathNameList.length - 1; index++) {
      if (customDir.length > 0) {
        customDir = customDir + '/' + dbPathNameList[index];
      } else {
        customDir = dbPathNameList[index];
      }
    }

    // 从系统中获取
    let config: relationalStore.StoreConfig;
    let readOnly:boolean = call.argument(Constant.PARAM_READ_ONLY) == undefined ? false : call.argument(Constant.PARAM_READ_ONLY);
    if (customDir.length > 0) {
      config = {
        name: dbName, // 数据库文件名
        securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
        customDir: customDir,
        isReadOnly:readOnly
      };
    } else {
      config = {
        name: dbName, // 数据库文件名
        securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
        isReadOnly:readOnly
      }
    }

    try {
      let rdbStore = await relationalStore.getRdbStore(context, config);
      DatabaseHelper.databaseList.set(dbName, rdbStore);
      DatabaseHelper.databaseId = DatabaseHelper.databaseId + 1;
      id = DatabaseHelper.databaseId;
      DatabaseHelper.databaseIdList.set(id, dbName);
      let map: Record<string, Object> = {
        'id': id,
        'recovered': false,
        'recoveredInTransaction': false,
      }
      result.success(map);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      result.error(Constant.SQLITE_ERROR, 'Error code: ' + code + 'error message: ' + message + '。', 'open database failed');
    }
    return id;
  }

  /// 检查数据库是否存在
  public static async checkDatabaseExisted(dbPath: string): Promise<boolean> {
    let dbPathNameList: Array<string> = dbPath.split('/');
    let dbName: string = dbPathNameList[dbPathNameList.length - 1];
    let endWithDb: boolean = Tools.stringEndWith(dbName, '.db');

    let trueDbPath: string = '';
    if (dbPathNameList.length > 6) {
      for (let index = 0; index < dbPathNameList.length; index++) {
        const element = dbPathNameList[index] as string;
        if ((index < 5) || (index > 5 && index != dbPathNameList.length - 1)) {
          trueDbPath = trueDbPath + element + '/';
        } else if (index == 5) {
          trueDbPath = trueDbPath + 'rdb' + '/';
          trueDbPath = trueDbPath + element + '/';
        } else {
          if (!endWithDb) {
            trueDbPath = trueDbPath + element + '.db';
          } else {
            trueDbPath = trueDbPath + element;
          }
        }
      }
    } else {
      for (let index = 0; index < dbPathNameList.length; index++) {
        const element = dbPathNameList[index] as string;
        if (index != dbPathNameList.length - 1) {
          trueDbPath = trueDbPath + element + '/';
        } else {
          trueDbPath = trueDbPath + 'rdb' + '/';
          if (!endWithDb) {
            trueDbPath = trueDbPath + element + '.db';
          } else {
            trueDbPath = trueDbPath + element;
          }
        }
      }
    }
    let isExists: boolean = await fs.access(trueDbPath);
    return isExists;
  }

  /// 从已加载的列表里获取一个数据库
  private static getOnlyLocal(databaseName: string): relationalStore.RdbStore | null {
    if (DatabaseHelper.databaseList.has(databaseName)) {
      return DatabaseHelper.databaseList.get(databaseName) as relationalStore.RdbStore | null;
    }
    return null;
  }

  /// 从已加载的列表里获取一个数据库
  public static getDatabaseOrError(call: MethodCall, result: MethodResult): relationalStore.RdbStore | null {
    let databaseId: number = call.argument("id");
    let databaseName: string | undefined = DatabaseHelper.databaseIdList.get(databaseId);
    if (typeof databaseName == undefined) {
      result.error('sqlite_error', "database_closed" + "" + databaseId, null);
      return null;
    }
    let rdbStore = DatabaseHelper.getOnlyLocal(databaseName as string);
    if (rdbStore != null) {
      return rdbStore;
    } else {
      result.error('sqlite_error', "database_closed" + "" + databaseId, null);
      return null;
    }
  }

  /// 关闭一个数据库
  public static async closeDatabase(call: MethodCall, result: MethodResult): Promise<void> {
    let databaseId: number = call.argument(Constant.PARAM_ID);
    let databaseName: string | undefined = DatabaseHelper.databaseIdList.get(databaseId);
    if (databaseName == undefined) return;
    if (DatabaseHelper.databaseList.has(databaseName)) {
      let local: relationalStore.RdbStore | null = DatabaseHelper.getOnlyLocal(databaseName);
      if (local != null) {
        try {
          await local.close();
          DatabaseHelper.databaseList.delete(databaseName);
          let id: number = -1;
          DatabaseHelper.databaseIdList.forEach((value, key) => {
            if (databaseName == value) {
              id = key;
            }
          })
          if (id > -1) {
            DatabaseHelper.databaseIdList.delete(id);
            result.success(null);
            return;
          }
        } catch (err) {
          let code = (err as BusinessError).code;
          let message = (err as BusinessError).message;
          result.error('sqlite_error', "close database failed. " + 'error code:' + code + '.  message:' + message, null);
          return;
        }
      }

    }
    result.error('sqlite_error', "close database failed, database is not exist, can not close" + " " + databaseId, null);
  }

  /// 删除一个数据库
  public static async deleteDatabase(context: common.Context, databaseName: string): Promise<boolean> {
    let result: boolean = false;
    let dbNameList: string[] = databaseName.split('/');
    let dbName: string = dbNameList[dbNameList.length - 1];
    let endWithDb: boolean = Tools.stringEndWith(dbName, '.db');
    if (!endWithDb) {
      dbName = dbName + '.db';
      databaseName = databaseName + '.db';
    }

    //自定义数据库路径
    let customDir: string = '';
    for (let index = 5; index < dbNameList.length - 1; index++) {
      if (customDir.length > 0) {
        customDir = customDir + '/' + dbNameList[index];
      } else {
        customDir = dbNameList[index];
      }
    }

    // 从系统中获取
    let config: relationalStore.StoreConfig;
    if (customDir.length > 0) {
      config = {
        name: dbName, // 数据库文件名
        securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
        customDir: customDir,
      };
    } else {
      config = {
        name: dbName, // 数据库文件名
        securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
      }
    }

    if (DatabaseHelper.databaseList.has(databaseName)) {
      DatabaseHelper.databaseList.delete(databaseName);
      let id: number = -1;
      DatabaseHelper.databaseIdList.forEach((value, key) => {
        if (databaseName == value) {
          id = key;
        }
      })
      if (id > -1) {
        DatabaseHelper.databaseIdList.delete(id);
        await relationalStore.deleteRdbStore(context, config);
        result = true;
        return result;
      }
      return result;
    } else {
      try {
        await relationalStore.deleteRdbStore(context, config);
        result = true;
        return result;
      } catch (e) {
        return result;
      }
    }
  }

  /// 获取设备版本信息
  public static async getPlatformVersion(call: MethodCall, result: MethodResult): Promise<void> {
    result.success('ohos' + deviceInfo.osFullName);
  }

  /// Options操作，设置LogLevel，仅限开发，已被废弃
  public static async options(call: MethodCall, result: MethodResult): Promise<void> {
    let logLevel: number | undefined = call.argument(Constant.PARAM_LOG_LEVEL);
    result.success(null);
  }

  /// 设置debug模式，查看SQL查询，已弃用
  public static async debugMode(call: MethodCall, result: MethodResult): Promise<void> {
    let on: boolean = call.args;
    result.success(null);
  }
}