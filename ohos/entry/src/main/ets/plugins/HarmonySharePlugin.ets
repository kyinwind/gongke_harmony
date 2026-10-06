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
import { systemShare } from '@kit.ShareKit';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';
import { fileUri } from '@kit.CoreFileKit';

const CHANNEL_NAME = 'gongke/share';

export default class HarmonySharePlugin
  implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private appContext: common.UIAbilityContext | null = null;

  getUniqueClassName(): string {
    return 'HarmonySharePlugin';
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
    if (call.method !== 'shareText' && call.method !== 'shareJson' && call.method !== 'shareFile') {
      result.notImplemented();
      return;
    }
    if (this.appContext === null) {
      result.error('no_context', 'UIAbilityContext is unavailable.', null);
      return;
    }
    const title = call.argument('title') as string ?? '';
    const isFile = call.method === 'shareFile';
    const contentKey = call.method === 'shareJson' ? 'json' : (isFile ? 'path' : 'text');
    const rawContent = call.argument(contentKey) as string ?? '';
    if (rawContent.trim().length === 0) {
      result.error('empty_content', 'Share content is empty.', null);
      return;
    }
    // 关键：文件必须走 SharedRecord.uri 字段（分享面板会对目标应用做临时授权），
    // 塞进 content 会被当成纯文本记录，微信拉起后拿不到文件。
    // 文本类走 content 字段。
    const record: systemShare.SharedRecord = isFile
      ? {
        utd: call.argument('utd') as string ?? 'general.file',
        uri: fileUri.getUriFromPath(rawContent),
        title: title,
        description: title
      }
      : {
        utd: call.method === 'shareJson' ? 'general.json' : 'general.plain-text',
        content: rawContent,
        title: title,
        description: title
      };
    try {
      const data = new systemShare.SharedData(record);
      const controller = new systemShare.ShareController(data);
      await controller.show(this.appContext, {
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      result.success(null);
    } catch (error) {
      result.error('share_error', `${error}`, null);
    }
  }
}
