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
import { fileUri } from '@kit.CoreFileKit';

const CHANNEL_NAME = 'gongke/widgets';
const PREFERENCES_NAME = 'gongke_widget_snapshots';
const INSTANCES_KEY = 'form_instances';

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
      for (let index = 0; index < formIds.length; index++) {
        const formId = formIds[index];
        const formName = instances[formId];
        try {
          if (changedNames.includes(formName)) {
            const snapshot = snapshots[formName] ?? store.getSync(formName, '{}') as string;
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
