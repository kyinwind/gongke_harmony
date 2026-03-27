import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/view/gongke/fayuan_wizard.dart';
import 'dart:io';
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
import '/viewmodel/share_card.dart';
// 导入 path_provider 库以使用 getApplicationDocumentsDirectory 函数
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'welcome.dart'; // 导入你的 WelcomePage

import 'package:toastification/toastification.dart';

// 声明全局数据库变量
late AppDatabase globalDB; // 在main函数中创建单一实例;

// 声明全局变量 app第一次运行的日期，用于后续显示开示
late String? firstDate;

void main() async {
  // 添加这一行来初始化 Flutter 绑定
  WidgetsFlutterBinding.ensureInitialized();

  // 等待 SharedPreferences 初始化
  await SharedPreferences.getInstance();
  final hasSeenWelcome = await getBoolValue('hasSeenWelcome') ?? false;
  // 根据平台选择合适的数据库存储路径
  late String dbPath;

  final dbFolder = await getApplicationSupportDirectory();
  dbPath = p.join(dbFolder.path, 'app.db');

  final executor = NativeDatabase(File(dbPath));
  globalDB = AppDatabase(executor);

  // 检查并存储首次运行时间
  firstDate = await getDateValue('firstDate');
  if (firstDate == null) {
    await saveDateValue('firstDate', DateTime.now());
  }
  WidgetsFlutterBinding.ensureInitialized();
  //print(firstDate);
  runApp(
    ProviderScope(
      child: ToastificationWrapper(
        child: MyApp(db: globalDB, hasSeenWelcome: hasSeenWelcome),
      ),
    ),
  ); // 传入数据库实例
}

class MyApp extends StatefulWidget {
  final AppDatabase db; // 添加数据库字段
  final bool hasSeenWelcome;
  const MyApp({
    super.key,
    required this.db,
    required this.hasSeenWelcome,
  }); // 修改构造函数

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasSeenWelcome = false;

  @override
  void initState() {
    super.initState();
    _hasSeenWelcome = widget.hasSeenWelcome;
  }

  Future<void> _finishWelcome() async {
    await saveBoolValue('hasSeenWelcome', true);
    setState(() {
      _hasSeenWelcome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String fontFamily;
    if (Platform.isWindows) {
      fontFamily = 'SimSun';
    } else {
      fontFamily = 'Roboto';
    }
    return MaterialApp(
      // title: '诵经助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: fontFamily),
        ).apply(fontFamily: fontFamily),
      ),
      home: _hasSeenWelcome
          ? TabbedHomePage(title: '诵经助手')
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
        '/ShareCardPage': (context) => const ShareCardPage(),
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
    TipPage(), // 传入数据库实例
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
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '开示'),
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
