import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/comm/platform_tools.dart';
import 'package:gongke/view/gongke/fayuan_wizard.dart';
import 'view/gongke/gongke.dart';
import 'view/gongke/modify_fayuanwen.dart';
import 'view/gongke/gongke_setting.dart';
import 'view/gongke/nianshenghao.dart';
import 'view/gongke/dazuo.dart';
import 'view/gongke/nianzhou.dart';
import 'view/gongke/gongke_stat.dart';
import 'database.dart';
import 'view/songjing/songjing.dart';
import 'view/tips/tip.dart';
import 'view/tips/add_tip.dart';
import 'view/tips/tip_record.dart';
import 'view/tips/add_tip_record.dart';
import 'view/tips/import_tips.dart';
import 'view/baichan/bai_chan.dart';
import 'view/baichan/new_bai_chan.dart';
import 'view/baichan/bai_chan_play.dart';
import 'view/setting/setting_page.dart';
import 'view/shanshu/shanshu.dart';
import 'view/songjing/import_files.dart';
import 'welcome.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 声明全局数据库变量
late AppDatabase globalDB; // 在main函数中创建单一实例;

// 声明全局变量 app第一次运行的日期，用于后续显示开示
late String? firstDate;

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
    debugPrintStack(stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapResult {
  const BootstrapResult({
    required this.db,
    required this.hasSeenWelcome,
    required this.hasAcceptedPrivacyPolicy,
  });

  final AppDatabase db;
  final bool hasSeenWelcome;
  final bool hasAcceptedPrivacyPolicy;
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<BootstrapResult> _bootstrapFuture = _bootstrap();

  Future<BootstrapResult> _bootstrap() async {
    final hasSeenWelcome = await getBoolValue('hasSeenWelcome') ?? false;
    final hasAcceptedPrivacyPolicy =
        await getBoolValue('hasAcceptedPrivacyPolicy') ?? false;

    globalDB = AppDatabase();
    await globalDB.customSelect('SELECT 1').get();

    firstDate = await getDateValue('firstDate');
    if (firstDate == null) {
      await saveDateValue('firstDate', DateTime.now());
    }

    return BootstrapResult(
      db: globalDB,
      hasSeenWelcome: hasSeenWelcome,
      hasAcceptedPrivacyPolicy: hasAcceptedPrivacyPolicy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BootstrapResult>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: SizedBox.expand(),
            ),
          );
        }

        if (snapshot.hasError) {
          return BootstrapStatusApp(
            title: '初始化失败',
            message: snapshot.error.toString(),
            details: snapshot.stackTrace?.toString(),
          );
        }

        final data = snapshot.requireData;
        return MyApp(
          db: data.db,
          initialHasSeenWelcome: data.hasSeenWelcome,
          initialHasAcceptedPrivacyPolicy: data.hasAcceptedPrivacyPolicy,
        );
      },
    );
  }
}

class BootstrapStatusApp extends StatelessWidget {
  const BootstrapStatusApp({
    super.key,
    required this.title,
    required this.message,
    this.details,
  });

  final String title;
  final String message;
  final String? details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 20)),
                if (details != null && details!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SelectableText(details!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final AppDatabase db; // 添加数据库字段
  final bool initialHasSeenWelcome;
  final bool initialHasAcceptedPrivacyPolicy;

  const MyApp({
    super.key,
    required this.db,
    required this.initialHasSeenWelcome,
    required this.initialHasAcceptedPrivacyPolicy,
  }); // 修改构造函数

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late bool _hasSeenWelcome = widget.initialHasSeenWelcome;
  late bool _hasAcceptedPrivacyPolicy =
      widget.initialHasAcceptedPrivacyPolicy;
  bool _isPrivacyDialogVisible = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _finishWelcome() async {
    await saveBoolValue('hasSeenWelcome', true);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasSeenWelcome = true;
    });
    _ensurePrivacyDialogIfNeeded();
  }

  void _ensurePrivacyDialogIfNeeded() {
    if (!_hasSeenWelcome || _hasAcceptedPrivacyPolicy || _isPrivacyDialogVisible) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialogContext = _navigatorKey.currentContext;
      if (!mounted ||
          dialogContext == null ||
          !_hasSeenWelcome ||
          _hasAcceptedPrivacyPolicy ||
          _isPrivacyDialogVisible) {
        return;
      }
      _showPrivacyPolicyDialog(dialogContext);
    });
  }

  Future<void> _showPrivacyPolicyDialog(BuildContext dialogContext) async {
    _isPrivacyDialogVisible = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (popupContext) => AlertDialog(
        title: const Text('隐私说明'),
        content: const SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Text(
              '本软件尊重并保护所有使用服务用户的个人隐私权。本软件不会收集您的个人信息，也不会存储和向第三方提供您的个人信息。本软件会不时更新本隐私权政策。您在同意本软件服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于本软件服务使用协议不可分割的一部分。\n\n'
              '1.适用范围\n\n'
              'a)在您使用本软件期间，本软件不会收集您的个人信息，本软件也不具备联网访问其他网站信息的功能，所以请放心使用本软件。\n\n'
              '2.信息披露\n\n'
              'a)本软件不会收集也不会将您的信息披露给不受信任的第三方。\n\n'
              '3.信息存储和交换\n\n'
              '本软件不会收集也不会存储您的个人信息。',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(popupContext).pop();
              await SystemNavigator.pop();
            },
            child: const Text('退出'),
          ),
          FilledButton(
            onPressed: () async {
              await saveBoolValue('hasAcceptedPrivacyPolicy', true);
              if (!popupContext.mounted || !mounted) {
                return;
              }
              setState(() {
                _hasAcceptedPrivacyPolicy = true;
              });
              Navigator.of(popupContext).pop();
            },
            child: const Text('同意'),
          ),
        ],
      ),
    );
    _isPrivacyDialogVisible = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensurePrivacyDialogIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensurePrivacyDialogIfNeeded();
    final fontFamily = PlatformUtils.preferredFontFamily;
    return MaterialApp(
      // title: '诵经助手',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: fontFamily),
        ).apply(fontFamily: fontFamily),
      ),
      home: _hasSeenWelcome
          ? const TabbedHomePage(title: '诵经助手')
          : WelcomePage(onFinish: _finishWelcome),
      // 添加路由配置
      routes: {
        '/Tip': (context) => const TipPage(),
        '/AddTip': (context) => const AddTipPage(),
        '/ImportTip': (context) => const ImportTipPage(),
        '/TipRecord': (context) => const TipRecordPage(),
        '/AddTipRecord': (context) => const AddTipRecordPage(),
        '/GongKe/FaYuanWizard': (context) => const FaYuanWizardPage(),
        '/GongKe/ModifyFaYuanWen': (context) => const ModifyFaYuanWenPage(),
        '/GongKe/GongKeSetting': (context) => const GongKeSettingPage(),
        '/GongKe/GongKeSetting/nianzhou': (context) => const NianzhouPage(),
        '/GongKe/GongKeSetting/nianshenghao': (context) =>
            const NianShengHaoPage(),
        '/GongKe/GongKeSetting/dazuo': (context) => const DaZuoPage(),
        '/GongKeStat': (context) => const GongKeStatPage(),
        '/BaiChan': (context) => const BaiChanPage(),
        '/BaiChan/NewBaiChan': (context) => const NewBaiChanPage(),
        '/BaiChan/BaiChanPlay': (context) => const BaiChanPlayPage(),
        '/Setting': (context) => const SettingPage(),
        '/ImportFiles': (context) => const ImportFilesPage(),
      },
      initialRoute: '/',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN')],
      locale: const Locale('zh', 'CN'),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.db.close();
    super.dispose();
  }
}

class TabbedHomePage extends StatefulWidget {
  const TabbedHomePage({super.key, required this.title});
  final String title;
  @override
  State<TabbedHomePage> createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions() => <Widget>[
        GongKePage(),
        SongJingPage(),
        ShanShuPage(),
        //TipPage(), // 传入数据库实例
        BaiChanPage(),
        SettingPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions().elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '功课'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '诵经'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: '善书'),
          //BottomNavigationBarItem(icon: Icon(Icons.chat), label: '开示'),
          BottomNavigationBarItem(icon: Icon(Icons.announcement), label: '拜忏'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 241, 214, 4),
        unselectedItemColor: Colors.grey,
        // 确保显示激活标签的文字
        showSelectedLabels: true,
        // 确保显示未激活标签的文字
        showUnselectedLabels: true,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
