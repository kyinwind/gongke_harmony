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
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';

const CHANNEL_NAME = 'gongke/external_launcher';

export default class OhosExternalLauncherPlugin
  implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private appContext: common.UIAbilityContext | null = null;
  private ability: UIAbility | null = null;

  getUniqueClassName(): string {
    return 'OhosExternalLauncherPlugin';
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
  }

  onDetachedFromAbility(): void {
    this.ability = null;
    this.appContext = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'launch':
        this.handleLaunch(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private async handleLaunch(call: MethodCall, result: MethodResult): Promise<void> {
    if (this.appContext == null) {
      result.error('no_context', 'UIAbilityContext is unavailable.', null);
      return;
    }
    const rawLink = call.argument('link') as Object | null;
    const link = rawLink === null ? '' : `${rawLink}`.trim();
    if (!link.length) {
      result.error('empty_link', 'Link is empty.', null);
      return;
    }

    try {
      await this.appContext.openLink(link);
      result.success(null);
    } catch (error) {
      const businessError = error as BusinessError;
      result.error(
        'launch_error',
        businessError?.message ?? 'Failed to open link.',
        `${businessError?.code ?? ''}`,
      );
    }
  }
}
