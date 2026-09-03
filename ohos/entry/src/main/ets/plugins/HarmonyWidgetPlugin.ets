import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { formBindingData, formProvider } from '@kit.FormKit';
import { preferences } from '@kit.ArkData';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { WidgetSnapshotRepository } from '../widget/WidgetSnapshotRepository';

const CHANNEL_NAME = 'gongke/widgets';
const PREFERENCES_NAME = 'gongke_widget_snapshots';
const INSTANCES_KEY = 'form_instances';
const TIP_CATALOG_FILE = 'today_tip_catalog.json';
const TIP_CATALOG_KEY = 'TodayTipCatalog';

export default class HarmonyWidgetPlugin
  implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private appContext: common.UIAbilityContext | null = null;

  getUniqueClassName(): string {
    return 'HarmonyWidgetPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    const ability = binding.getAbility() as UIAbility;
    this.appContext = ability.context;
  }

  onDetachedFromAbility(): void {
    this.appContext = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'writeSnapshots') {
      result.notImplemented();
      return;
    }
    if (this.appContext === null) {
      result.error('no_context', 'UIAbilityContext is unavailable.', null);
      return;
    }
    try {
      const store = preferences.getPreferencesSync(this.appContext, { name: PREFERENCES_NAME });
      const snapshots: Record<string, string> = {
        'TodayTasksCard': call.argument('TodayTasksCard') as string ?? '{}',
        'TodayTipCard': call.argument('TodayTipCard') as string ?? '{}',
        'GongKeCalendarCard': call.argument('GongKeCalendarCard') as string ?? '{}'
      };
      const namesText = call.argument('cardNames') as string ?? '[]';
      const changedNames = JSON.parse(namesText) as string[];
      if (changedNames.includes('TodayTipCard')) {
        const catalogText = call.argument('TodayTipCatalog') as string ?? '{}';
        const catalog = JSON.parse(catalogText) as Record<string, Object>;
        const books = catalog['books'] as Record<string, Object>[] ?? [];
        books.forEach((book: Record<string, Object>) => {
          const imagePath = book['imagePath'] as string ?? '';
          if (imagePath.length > 0) book['imageUri'] = fileUri.getUriFromPath(imagePath);
        });
        const file = fileIo.openSync(
          `${this.appContext.filesDir}/${TIP_CATALOG_FILE}`,
          fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC,
        );
        try {
          fileIo.writeSync(file.fd, JSON.stringify(catalog));
        } finally {
          fileIo.closeSync(file);
        }
        // Preferences is already proven to be shared by UIAbility and the
        // Form extension. Keep the complete catalog there as the primary
        // source, with the file as a mac-style durable fallback.
        store.putSync(TIP_CATALOG_KEY, JSON.stringify(catalog));
      }
      changedNames.forEach((name: string) => {
        let snapshot = snapshots[name];
        if (name === 'TodayTipCard') {
          const tip = JSON.parse(snapshot) as Record<string, Object>;
          const imagePath = tip['imagePath'] as string ?? '';
          if (imagePath.length > 0) tip['imageUri'] = fileUri.getUriFromPath(imagePath);
          snapshot = JSON.stringify(tip);
          snapshots[name] = snapshot;
        }
        store.putSync(name, snapshot);
      });
      await store.flush();
      const instancesText = store.getSync(INSTANCES_KEY, '{}') as string;
      const instances = JSON.parse(instancesText) as Record<string, string>;
      // API 20+ 直接从系统查询正在运行的卡片，避免仅依赖本地登记造成
      // 新增、删除或桌面恢复卡片后实例列表过期。旧系统仍使用本地登记回退。
      try {
        const runningForms = await formProvider.getPublishedRunningFormInfos();
        runningForms.forEach((form) => {
          instances[form.formId] = form.formName;
        });
      } catch (_) {
        // API 20 以下或系统暂时不可用时，继续使用 onAddForm 保存的实例。
      }
      const formIds = Object.keys(instances);
      const retainedInstances: Record<string, string> = {};
      const repository = new WidgetSnapshotRepository(this.appContext);
      for (let index = 0; index < formIds.length; index++) {
        const formId = formIds[index];
        const formName = instances[formId];
        try {
          if (changedNames.includes(formName)) {
            // FormBindingData updates are incremental. Always decorate every
            // card from the just-written snapshot so runtime-only fields such
            // as staleLevel/staleMessage are explicitly overwritten. Sending
            // raw task/calendar snapshots would leave yesterday's warning in
            // place even after generatedAt had advanced to today.
            const snapshot = JSON.stringify(repository.readForForm(formId, formName));
            await formProvider.updateForm(
              formId,
              formBindingData.createFormBindingData(JSON.parse(snapshot) as object),
            );
          }
          retainedInstances[formId] = formName;
        } catch (_) {
          // 单张卡片已被删除或实例失效时跳过并清理，不能阻断其他卡片刷新。
        }
      }
      store.putSync(INSTANCES_KEY, JSON.stringify(retainedInstances));
      await store.flush();
      result.success(null);
    } catch (error) {
      result.error('widget_sync_error', `${error}`, null);
    }
  }
}
