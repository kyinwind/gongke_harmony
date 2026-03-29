import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { textToSpeech } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';

const CHANNEL_NAME = 'gongke/tts';

class PendingSpeak {
  text: string = '';
  requestId: string = '';
  rate: number = 1.0;
  pitch: number = 1.0;
}

export default class OhosTtsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private engine: textToSpeech.TextToSpeechEngine | null = null;
  private isInitializing: boolean = false;
  private pendingSpeak: PendingSpeak | null = null;
  private currentRequestId: string = '';

  getUniqueClassName(): string {
    return 'OhosTtsPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.ensureEngine();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.stopInternal();
    this.engine?.shutdown();
    this.engine = null;
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'speak':
        this.handleSpeak(call, result);
        break;
      case 'stop':
        this.stopInternal();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  private handleSpeak(call: MethodCall, result: MethodResult): void {
    const text = this.readRequiredText(call, 'text');
    const requestId = this.readStringArgument(call, 'requestId', `${Date.now()}`);
    const rate = this.readNumberArgument(call, 'rate', 1.0);
    const pitch = this.readNumberArgument(call, 'pitch', 1.0);

    if (!text.length) {
      result.error('empty_text', 'TTS text is empty.', null);
      return;
    }

    let pendingSpeak = new PendingSpeak();
    pendingSpeak.text = text;
    pendingSpeak.requestId = requestId;
    pendingSpeak.rate = rate;
    pendingSpeak.pitch = pitch;
    this.pendingSpeak = pendingSpeak;
    this.ensureEngine(() => this.startPendingSpeak());
    result.success(null);
  }

  private ensureEngine(onReady?: () => void): void {
    if (this.engine) {
      onReady?.();
      return;
    }
    if (this.isInitializing) {
      return;
    }

    this.isInitializing = true;
    const initParams: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: {
        style: 'interaction-broadcast',
        locate: 'CN',
        name: 'gongkeHarmonyTts',
      },
    };

    textToSpeech.createEngine(
      initParams,
      (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
        this.isInitializing = false;
        if (err) {
          this.channel?.invokeMethod('onError', {
            requestId: this.pendingSpeak?.requestId ?? '',
            code: `${err.code}`,
            message: err.message,
          });
          return;
        }

        this.engine = engine;
        this.engine.setListener({
          onStart: (requestId: string) => {
            console.info(`[gongke_tts] onStart ${requestId}`);
            this.channel?.invokeMethod('onStart', { requestId });
          },
          onComplete: (requestId: string) => {
            if (this.currentRequestId === requestId) {
              this.currentRequestId = '';
            }
            console.info(`[gongke_tts] onComplete ${requestId}`);
            this.channel?.invokeMethod('onComplete', { requestId });
          },
          onStop: (requestId: string) => {
            if (this.currentRequestId === requestId) {
              this.currentRequestId = '';
            }
            console.info(`[gongke_tts] onStop ${requestId}`);
            this.channel?.invokeMethod('onStop', { requestId });
          },
          onData: (requestId: string, audio: ArrayBuffer) => {},
          onError: (requestId: string, errorCode: number, errorMessage: string) => {
            if (this.currentRequestId === requestId) {
              this.currentRequestId = '';
            }
            console.error(
              `[gongke_tts] onError ${requestId} ${errorCode} ${errorMessage}`,
            );
            this.channel?.invokeMethod('onError', {
              requestId,
              code: `${errorCode}`,
              message: errorMessage,
            });
          },
        });
        onReady?.();
      },
    );
  }

  private startPendingSpeak(): void {
    const speak = this.pendingSpeak;
    if (!this.engine || !speak) {
      return;
    }

    this.stopInternal();
    this.pendingSpeak = null;
    this.currentRequestId = speak.requestId;

    const speakParams: textToSpeech.SpeakParams = {
      requestId: speak.requestId,
      extraParams: {
        queueMode: 0,
        speed: speak.rate,
        volume: 1.0,
        pitch: speak.pitch,
        languageContext: 'zh-CN',
        soundChannel: 3,
        playType: 1,
      },
    };
    this.engine.speak(speak.text, speakParams);
  }

  private stopInternal(): void {
    if (!this.engine) {
      this.currentRequestId = '';
      this.pendingSpeak = null;
      return;
    }
    if (this.engine.isBusy()) {
      this.engine.stop();
    }
    this.currentRequestId = '';
    this.pendingSpeak = null;
  }

  private readRequiredText(call: MethodCall, key: string): string {
    const raw: Object | null = call.argument(key) as Object | null;
    if (raw === null) {
      return '';
    }
    return `${raw}`.trim();
  }

  private readStringArgument(call: MethodCall, key: string, fallback: string): string {
    const raw: Object | null = call.argument(key) as Object | null;
    if (raw === null) {
      return fallback;
    }
    const value = `${raw}`.trim();
    return value.length ? value : fallback;
  }

  private readNumberArgument(call: MethodCall, key: string, fallback: number): number {
    const raw: Object | null = call.argument(key) as Object | null;
    return this.toNumber(raw, fallback);
  }

  private toNumber(value: Object | null | undefined, fallback: number): number {
    if (value === undefined || value === null) {
      return fallback;
    }
    if (typeof value === 'number') {
      return Number.isNaN(value) ? fallback : value;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? fallback : parsed;
  }
}
