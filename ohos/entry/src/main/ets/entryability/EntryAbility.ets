
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import OhosExternalLauncherPlugin from '../plugins/OhosExternalLauncherPlugin';
import OhosSensorPlugin from '../plugins/OhosSensorPlugin';
import OhosTtsPlugin from '../plugins/OhosTtsPlugin';
import OhosVibrationPlugin from '../plugins/OhosVibrationPlugin';
import OhosWakelockPlugin from '../plugins/OhosWakelockPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new OhosExternalLauncherPlugin())
    flutterEngine.getPlugins()?.add(new OhosSensorPlugin())
    flutterEngine.getPlugins()?.add(new OhosTtsPlugin())
    flutterEngine.getPlugins()?.add(new OhosVibrationPlugin())
    flutterEngine.getPlugins()?.add(new OhosWakelockPlugin())
  }
}
