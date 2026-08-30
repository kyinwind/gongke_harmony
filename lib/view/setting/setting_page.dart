import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:gongke/view/help/help_center_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

const double picheight = 400;
const String feedbackEmail = 'yangxuehui@outlook.com';

class _SettingPageState extends State<SettingPage> {
  static const _appInfoChannel = MethodChannel('gongke/app_info');
  late final Future<String> _versionText;

  @override
  void initState() {
    super.initState();
    _versionText = _loadVersionText();
  }

  Future<String> _loadVersionText() async {
    try {
      final info = await _appInfoChannel.invokeMapMethod<String, dynamic>(
        'getVersion',
      );
      final versionName = info?['versionName']?.toString() ?? '';
      final versionCode = info?['versionCode']?.toString() ?? '';
      if (versionName.isNotEmpty && versionCode.isNotEmpty) {
        return '版本 $versionName（$versionCode）';
      }
      if (versionName.isNotEmpty) return '版本 $versionName';
    } catch (_) {
      // “关于”正文仍可正常展示，版本读取失败时给出明确占位。
    }
    return '版本信息暂不可用';
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
              _buildSection(
                '帮助中心',
                const HelpCenterEntryTile(),
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('反馈方式'),
                  subtitle: const SelectableText(feedbackEmail),
                  trailing: IconButton(
                    tooltip: '复制邮箱',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () {
                      copyToClipboard(feedbackEmail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('反馈邮箱已复制')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '界面一览',
                CarouselSlider(
                  options: CarouselOptions(
                    height: picheight + 150,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                    enlargeFactor: 0.3,
                  ),
                  items: _buildImageSliders(context),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '关于',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _versionText,
                      builder: (context, snapshot) => Text(
                        snapshot.data ?? '正在读取版本…',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '''  作者本人为了日常做学佛的功课，所以才起意制作了本app分享，希望也能帮到各位佛友。
  在此鸣谢下列单位、人员以及各个flutter组件的开发者（恕不能一一列出人名，仅列出使用的组件）:
  仁慧草堂:本app所提供的经书电子版、图片多数来自于仁慧草堂分享，少数来自于网络收集。
  cupertino_icons、intl、styled_widget、sqlite3、drift、path_provider、path、fl_chart、shared_preferences、pdfx、flutter_slidable、image_picker、flutter_image_compress、table_calendar、lunar、sensors_plus、flutter_svg、audioplayers、carousel_slider、ffi、file_selector、url_launcher...''',
                      textAlign: TextAlign.left,
                    ),
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

  List<Widget> _buildImageSliders(BuildContext context) {
    final helpSlides = getHelpSlidesForWidth(MediaQuery.of(context).size.width);
    return helpSlides
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
                      border: Border.all(color: Colors.yellow, width: 1),
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
  }
}
