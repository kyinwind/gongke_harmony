
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import OhosTtsPlugin from '../plugins/OhosTtsPlugin';
import OhosWakelockPlugin from '../plugins/OhosWakelockPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new OhosTtsPlugin())
    flutterEngine.getPlugins()?.add(new OhosWakelockPlugin())
  }
}
