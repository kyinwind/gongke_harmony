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
import hilog from '@ohos.hilog';
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
      case 'launchEmail':
        this.handleLaunchEmail(call, result);
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
      if (link.toLowerCase().startsWith('mailto:')) {
        await this.appContext.startAbility({
          action: 'ohos.want.action.viewData',
          uri: link,
          type: 'message/rfc822'
        });
      } else {
        await this.appContext.openLink(link);
      }
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

  private async handleLaunchEmail(call: MethodCall, result: MethodResult): Promise<void> {
    if (this.appContext == null) {
      result.error('no_context', 'UIAbilityContext is unavailable.', null);
      return;
    }
    const recipient = `${call.argument('recipient') ?? ''}`.trim();
    const subject = `${call.argument('subject') ?? ''}`.trim();
    const body = `${call.argument('body') ?? ''}`;
    if (!recipient.length) {
      result.error('empty_recipient', 'Email recipient is empty.', null);
      return;
    }

    const wantParam: Record<string, Object> = {
      'sceneType': 1,
      'email': [encodeURI(recipient)],
      'subject': encodeURI(subject),
      'body': encodeURI(body)
    };
    let completed = false;
    const succeed = (): void => {
      if (completed) return;
      completed = true;
      hilog.info(0x0000, 'gongke', 'Default email ability started successfully.');
      result.success(null);
    };
    const fail = (code: number | string, message: string): void => {
      if (completed) return;
      completed = true;
      hilog.error(0x0000, 'gongke', 'Default email ability failed: %{public}s', `${code}:${message}`);
      result.error('launch_email_error', message, `${code}`);
    };
    const abilityStartCallback: common.AbilityStartCallback = {
      onError: (code: number, name: string, message: string): void => {
        fail(code, `${name}:${message}`);
      },
      onResult: (): void => {
        succeed();
      }
    };
    try {
      await this.appContext.startAbilityByType('mail', wantParam, abilityStartCallback);
    } catch (error) {
      const businessError = error as BusinessError;
      fail(
        businessError?.code ?? '',
        businessError?.message ?? 'Failed to open the default email application.',
      );
    }
  }
}
