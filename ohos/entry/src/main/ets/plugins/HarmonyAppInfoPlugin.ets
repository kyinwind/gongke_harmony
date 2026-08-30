import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { bundleManager } from '@kit.AbilityKit';

const CHANNEL_NAME = 'gongke/app_info';

export default class HarmonyAppInfoPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'HarmonyAppInfoPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'getVersion') {
      result.notImplemented();
      return;
    }
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      const version: Record<string, Object> = {
        'versionName': bundleInfo.versionName,
        'versionCode': bundleInfo.versionCode,
      };
      result.success(version);
    } catch (error) {
      result.error('app_info_error', `${error}`, null);
    }
  }
}
