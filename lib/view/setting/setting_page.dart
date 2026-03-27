import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gongke/comm/pub_tools.dart';
import '../../comm/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  State<SettingPage> createState() => _SettingPageState();
}

const double picheight = 400;

final help_sllides = Platform.isWindows
    ? help_slides_windows
    : help_slides_android;

final List<Widget> imageSliders = help_sllides
    .map(
      (item) => Container(
        margin: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow,
                    width: 1,
                  ), // 黄色边框，宽度为3
                ),
                child: SizedBox(
                  height: picheight,
                  child: Image.asset(
                    item['image']!,
                    fit: BoxFit.contain,
                    height: picheight,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item['title'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  item['description'] ?? '',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .toList();

class _SettingPageState extends State<SettingPage> {
  bool _allowWakelock = false;
  @override
  void initState() {
    super.initState();

    getBoolValue('allow_wakelock_flag').then((value) {
      setState(() {
        _allowWakelock = value ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Platform.isAndroid || Platform.isIOS
                  ? _buildSection(
                      '系统设置',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: const Text('允许听书时禁止息屏'),
                            value: _allowWakelock,
                            onChanged: (bool value) async {
                              print('-----------开关值：${value}');
                              // 处理开关状态改变的逻辑
                              setState(() {
                                _allowWakelock = value;
                                saveBoolValue('allow_wakelock_flag', value);
                              });
                            },
                          ),
                          const Text(
                            '如果允许，则听书时一直亮屏。反之则听两三页之后手机自动息屏。',
                            textAlign: TextAlign.left, // ✅ 添加对齐
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              _buildSection(
                '意见反馈',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '如有任何问题或建议，请发邮件给我，感谢您的反馈：',
                      textAlign: TextAlign.left, // ✅ 添加对齐
                    ),
                    SelectableText(
                      'yangxuehui@outlook.com',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.left, // ✅ 添加对齐
                    ),
                    ElevatedButton(
                      child: Text('https://tieba.baidu.com/p/9908596817'),
                      onPressed: () async {
                        final url = 'https://tieba.baidu.com/p/9908596817';
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          Toastification().show(
                            title: TextButton(
                              onPressed: () {
                                copyToClipboard(url);
                              },
                              child: Text('打开链接失败，请点击复制链接后手动打开'),
                            ),
                            type: ToastificationType.error,
                          );
                        }
                      },
                    ),
                    // const SelectableText(
                    //   '技术支持网站: https://tieba.baidu.com/p/9908596817',
                    //   textAlign: TextAlign.left,
                    // ),
                    // const SelectableText(
                    //   '技术支持qq:966451045',
                    //   textAlign: TextAlign.left,
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '使用帮助',
                CarouselSlider(
                  options: CarouselOptions(
                    height: picheight + 150,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                    enlargeFactor: 0.3,
                  ),
                  items: imageSliders,
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '关于',
                const Text(
                  '''  作者本人为了日常做学佛的功课，所以才起意制作了本app分享，希望也能帮到各位佛友。
  在此鸣谢下列单位、人员以及各个flutter组件的开发者（恕不能一一列出人名，仅列出使用的组件）:
  仁慧草堂:本app所提供的经书电子版、图片多数来自于仁慧草堂分享，少数来自于网络收集。
  cupertino_icons、intl、styled_widget、sqlite3、drift、drift_flutter、sqlite3_flutter_libs、path_provider、path、fl_chart、shared_preferences、pdfx、flutter_slidable、image_picker、flutter_image_compress、table_calendar、lunar、sensors_plus、flutter_svg、audioplayers、flutter_tts、carousel_slider、wakelock_plus、device_info_plus、flutter_pdf_text、flutter_foreground_task、pdfium_bindings、ffi、msix、file_picker、url_launcher...''',
                  textAlign: TextAlign.left, // ✅ 添加对齐
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '版本历史',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text('v1.0.6 (2025-09-09)', textAlign: TextAlign.left),
                    Text('• 功课设定界面、开示界面增加分享功能', textAlign: TextAlign.left),
                    Text('v1.0.5 (2025-08-30)', textAlign: TextAlign.left),
                    Text('• 诵经时可以播放电子木鱼', textAlign: TextAlign.left),
                    Text('v1.0.3 (2025-07-29)', textAlign: TextAlign.left),
                    Text('• 增加欢迎页面', textAlign: TextAlign.left),
                    Text('• 增加经书、善书、开示文件导入功能', textAlign: TextAlign.left),
                    Text('• 准备上架应用商店', textAlign: TextAlign.left),
                    Text('v1.0.0 (2025-07-19)', textAlign: TextAlign.left),
                    Text('• 准备上架应用商店', textAlign: TextAlign.left),
                    Text('• 增加华严经', textAlign: TextAlign.left),
                    Text('v0.9.7 (2025-07-12)', textAlign: TextAlign.left),
                    Text('• 增加打坐的计时功能', textAlign: TextAlign.left),
                    Text('• 增加善书', textAlign: TextAlign.left),
                    Text('v0.9.6 (2025-07-04)', textAlign: TextAlign.left),
                    Text('• 完善双页显示和缩略图显示', textAlign: TextAlign.left), // ✅
                    Text('v0.9.4 (2025-06-26)', textAlign: TextAlign.left), // ✅
                    Text(
                      '• 听书功能支持win平台\n• 增加坐禅系列电子书\n• 修改经书和善书按照名称排序',
                      textAlign: TextAlign.left,
                    ), // ✅
                    Text('v0.9.3 (2025-06-23)', textAlign: TextAlign.left), // ✅
                    Text(
                      '• 增加听书功能。\n• 更换饼图组件。',
                      textAlign: TextAlign.left,
                    ), // ✅
                    Text('v0.9.2 (2025-06-17)', textAlign: TextAlign.left), // ✅
                    Text(
                      '• 完善首页显示。\n• 完善开示录显示。\n• 完善拜忏显示。',
                      textAlign: TextAlign.left,
                    ), // ✅
                    Text('v0.9.1 (2025-06-11)', textAlign: TextAlign.left), // ✅
                    Text('• 完善pdf显示，增加善书页面', textAlign: TextAlign.left), // ✅
                    Text('v0.9.0 (2025-06-08)', textAlign: TextAlign.left), // ✅
                    Text('• 首次发布', textAlign: TextAlign.left), // ✅
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: content),
      ],
    );
  }
}
