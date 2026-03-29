import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import vibrator from '@ohos.vibrator';

const CHANNEL_NAME = 'gongke/vibration';

export default class OhosVibrationPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'OhosVibrationPlugin';
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
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    switch (call.method) {
      case 'vibrate':
        await this.vibrate(result);
        break;
      case 'stop':
        await this.stop(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private async vibrate(result: MethodResult): Promise<void> {
    try {
      await vibrator.startVibration(
        {
          type: 'time',
          duration: 100,
        },
        {
          id: 0,
          usage: 'touch',
        },
      );
      result.success(null);
    } catch (error) {
      result.error('vibrate_error', `${error}`, null);
    }
  }

  private async stop(result: MethodResult): Promise<void> {
    try {
      await vibrator.stopVibration();
      result.success(null);
    } catch (error) {
      result.error('vibrate_stop_error', `${error}`, null);
    }
  }
}
