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
import window from '@ohos.window';
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';

const CHANNEL_NAME = 'gongke/wakelock';

export default class OhosWakelockPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private appContext: common.UIAbilityContext | null = null;
  private ability: UIAbility | null = null;

  getUniqueClassName(): string {
    return 'OhosWakelockPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
    this.appContext = null;
    this.ability = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility();
    this.appContext = this.ability.context;
    console.info('[gongke_wakelock] attached to ability');
  }

  onDetachedFromAbility(): void {
    console.info('[gongke_wakelock] detached from ability');
    this.ability = null;
    this.appContext = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'enable':
        console.info('[gongke_wakelock] enable request');
        this.setKeepScreenOn(true, result);
        break;
      case 'disable':
        console.info('[gongke_wakelock] disable request');
        this.setKeepScreenOn(false, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private async setKeepScreenOn(isKeepScreenOn: boolean, result: MethodResult): Promise<void> {
    if (this.appContext == null) {
      console.error('[gongke_wakelock] no UIAbilityContext');
      result.error('no_context', 'UIAbilityContext is unavailable.', null);
      return;
    }
    try {
      const lastWindow = await window.getLastWindow(this.appContext);
      await lastWindow.setWindowKeepScreenOn(isKeepScreenOn);
      console.info(`[gongke_wakelock] setWindowKeepScreenOn success: ${isKeepScreenOn}`);
      result.success(null);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(
        `[gongke_wakelock] setWindowKeepScreenOn failed: ${isKeepScreenOn}, code=${businessError?.code ?? ''}, message=${businessError?.message ?? ''}`,
      );
      result.error(
        'wakelock_error',
        businessError?.message ?? 'Failed to update keep-screen-on state.',
        `${businessError?.code ?? ''}`,
      );
    }
  }
}
