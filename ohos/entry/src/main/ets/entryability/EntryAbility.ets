
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import OhosExternalLauncherPlugin from '../plugins/OhosExternalLauncherPlugin';
import OhosSensorPlugin from '../plugins/OhosSensorPlugin';
import OhosTtsPlugin from '../plugins/OhosTtsPlugin';
import OhosVibrationPlugin from '../plugins/OhosVibrationPlugin';
import OhosWakelockPlugin from '../plugins/OhosWakelockPlugin';
import HarmonyWidgetPlugin from '../plugins/HarmonyWidgetPlugin';
import HarmonySharePlugin from '../plugins/HarmonySharePlugin';
import HarmonyDeepLinkPlugin from '../plugins/HarmonyDeepLinkPlugin';
import HarmonyAppInfoPlugin from '../plugins/HarmonyAppInfoPlugin';

export default class EntryAbility extends FlutterAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    super.onWindowStageCreate(windowStage)
    try {
      const mainWindow = windowStage.getMainWindowSync()
      mainWindow.setPreferredOrientation(window.Orientation.PORTRAIT)
    } catch (error) {
      hilog.error(0x0000, 'gongke', 'Failed to lock portrait: %{public}s', JSON.stringify(error) ?? '')
    }
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new OhosExternalLauncherPlugin())
    flutterEngine.getPlugins()?.add(new OhosSensorPlugin())
    flutterEngine.getPlugins()?.add(new OhosTtsPlugin())
    flutterEngine.getPlugins()?.add(new OhosVibrationPlugin())
    flutterEngine.getPlugins()?.add(new OhosWakelockPlugin())
    flutterEngine.getPlugins()?.add(new HarmonyWidgetPlugin())
    flutterEngine.getPlugins()?.add(new HarmonySharePlugin())
    flutterEngine.getPlugins()?.add(new HarmonyDeepLinkPlugin())
    flutterEngine.getPlugins()?.add(new HarmonyAppInfoPlugin())
  }
}
