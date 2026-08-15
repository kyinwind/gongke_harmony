import {
  AbilityAware,
  AbilityPluginBinding,
  NewWantListener,
  FlutterAbility,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

const CHANNEL_NAME = 'gongke/deep_link';

export default class HarmonyDeepLinkPlugin
  implements FlutterPlugin, MethodCallHandler, AbilityAware, NewWantListener {
  private channel: MethodChannel | null = null;
  private binding: AbilityPluginBinding | null = null;
  private pending: Record<string, Object> | null = null;

  getUniqueClassName(): string { return 'HarmonyDeepLinkPlugin'; }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.binding = binding;
    binding.addOnNewWantListener(this);
    const ability = binding.getAbility() as FlutterAbility;
    this.pending = this.extract(ability.getWant());
  }

  onDetachedFromAbility(): void {
    if (this.binding !== null) this.binding.removeOnNewWantListener(this);
    this.binding = null;
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    const link = this.extract(want);
    if (link === null) return;
    this.pending = link;
    this.channel?.invokeMethod('onDeepLink', link);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method !== 'getInitialDeepLink') {
      result.notImplemented();
      return;
    }
    result.success(this.pending);
    this.pending = null;
  }

  private extract(want: Want): Record<string, Object> | null {
    const route = want.parameters?.['route'] as string ?? '';
    if (route !== 'tasks' && route !== 'calendar' && route !== 'tips') return null;
    const link: Record<string, Object> = { 'route': route };
    const bookId = want.parameters?.['bookId'] as number ?? 0;
    const recordId = want.parameters?.['recordId'] as number ?? 0;
    if (bookId > 0) link['bookId'] = bookId;
    if (recordId > 0) link['recordId'] = recordId;
    return link;
  }
}
