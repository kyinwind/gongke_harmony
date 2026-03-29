import {
  BinaryMessenger,
  EventChannel,
  EventSink,
  FlutterPlugin,
  FlutterPluginBinding,
  StreamHandler,
} from '@ohos/flutter_ohos';
import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

const ACCELEROMETER_CHANNEL_NAME = 'gongke/sensors/accelerometer';

class AccelerometerStreamHandler implements StreamHandler {
  private eventSink?: EventSink;
  private readonly callback: (data: sensor.AccelerometerResponse) => void;

  constructor() {
    this.callback = (data: sensor.AccelerometerResponse) => {
      if (!this.eventSink) {
        return;
      }
      this.eventSink.success([data.x, data.y, data.z]);
    };
  }

  onListen(args: ESObject, events: EventSink): void {
    this.eventSink = events;
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, this.callback, {
        interval: 100000000,
      });
    } catch (error) {
      const businessError = error as BusinessError;
      this.eventSink.error(
        `${businessError.code}`,
        businessError.message,
        null,
      );
    }
  }

  onCancel(args: ESObject): void {
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER, this.callback);
    } catch (_) {}
    this.eventSink = undefined;
  }
}

export default class OhosSensorPlugin implements FlutterPlugin {
  private accelerometerChannel: EventChannel | null = null;
  private accelerometerHandler: AccelerometerStreamHandler | null = null;

  getUniqueClassName(): string {
    return 'OhosSensorPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.setupEventChannels(binding.getBinaryMessenger());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.accelerometerChannel && this.accelerometerHandler) {
      this.accelerometerChannel.setStreamHandler(null);
    }
    this.accelerometerChannel = null;
    this.accelerometerHandler = null;
  }

  private setupEventChannels(messenger: BinaryMessenger): void {
    this.accelerometerChannel = new EventChannel(
      messenger,
      ACCELEROMETER_CHANNEL_NAME,
    );
    this.accelerometerHandler = new AccelerometerStreamHandler();
    this.accelerometerChannel.setStreamHandler(this.accelerometerHandler);
  }
}
