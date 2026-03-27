import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gongke/comm/date_tools.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:gongke/comm/logger_tools.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:gongke/viewmodel/current_record.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:toastification/toastification.dart';

class ShareCardPage extends StatefulWidget {
  const ShareCardPage({super.key});

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  final String symbol = "卍";
  List<GongKeItemData> gkitemdata = [];
  List<String> shareddata = [];
  String kaishi = "";
  String bookname = "";
  ScreenshotController screenshotController = ScreenshotController();
  String todayString() {
    final now = DateTime.now();
    return "${now.year}年 ${now.month}月 ${now.day}日";
  }

  final GlobalKey _previewContainer = GlobalKey();

  @override
  void initState() {
    super.initState();

    getShowCardData();
  }

  Future<void> getShowCardData() async {
    final String todayDate = DateTools.getStringByCurrentDate();
    gkitemdata = await globalDB.managers.gongKeItem
        .filter((f) => f.gongKeDay.equals(todayDate))
        .orderBy((o) => o.fayuanId.asc() & o.createDateTime.desc())
        .get();
    logger.i("查询出来今天功课一共${gkitemdata.length}");

    if (gkitemdata.length == 0) {
      shareddata.add("您今天还未制定功课计划，请进入应用制定您的功课计划吧。");
    } else {
      var iflag = true;
      for (var rec in gkitemdata) {
        if (rec.isComplete == false) {
          iflag = false;
          break;
        }
      }
      shareddata.add("今天您的功课:");
      for (var rec in gkitemdata) {
        var statustext = rec.isComplete ? "[OK]" : "[ToDo]";
        var danwei = getDanWei(rec.gongketype);
        var temp = rec.name + "${rec.cnt}$danwei" + statustext;
        shareddata.add(temp);
      }
      if (iflag) {
        shareddata.add("恭喜！您今天的功课已经全部完成！");
      } else {
        shareddata.add("功课还未全部完成，加油！");
      }
    }
    logger.i(shareddata);
    // 找到今天显示的开示
    final record = await getCurrentRecord();
    setState(() {
      kaishi = record.content;
      bookname = record.bookName;
    });
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32.0, // 增加上下内边距
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xfffaf9f0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.brown, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: SingleChildScrollView(
        // ✅ 允许内容滚动，不会溢出
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                todayString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "$symbol 今日功课打卡 $symbol",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 今日功课内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: shareddata.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // 开示内容
            if (kaishi.isNotEmpty && bookname.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "$symbol【每日开示】$symbol",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kaishi.length > 500
                        ? '${kaishi.substring(0, 500)}...'
                        : kaishi,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "《${bookname}》",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // 底部版权信息
            Center(
              child: Column(
                children: [
                  const Text(
                    "——诵经助手(又名功课助手)提供",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Text(
                    "微软或苹果应用商店免费下载",
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/icons/icon.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _captureImage() async {
    try {
      final mediaQuery = MediaQuery.of(context);
      final widgetToCapture = MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: 1.0),
        child: Theme(
          data: Theme.of(context),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            ),
            home: Material(
              color: const Color(0xfffaf9f0),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: mediaQuery.size.width - 32,
                  ),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ),
      );

      Uint8List pngBytes = await screenshotController.captureFromWidget(
        widgetToCapture,
        pixelRatio: 2.0,
        context: context,
      );

      return pngBytes;
    } catch (e) {
      print("截图失败: $e");
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f0), // 浅米色背景
      appBar: AppBar(
        title: const Text("分享功课"),
        //backgroundColor: Colors.brown.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Screenshot(
                controller: screenshotController,
                child: SingleChildScrollView(child: _buildCard()),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    // 截图分享

                    final capturedImage = await _captureImage();
                    if (capturedImage.isEmpty) {
                      toastification.show(
                        type: ToastificationType.error,
                        title: const Text('截图失败'),
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    final directory = await getTemporaryDirectory();
                    final tempPath =
                        '${directory.path}/share_card.png'; // 用 .png
                    await File(
                      tempPath,
                    ).writeAsBytes(capturedImage, flush: true);

                    final params = ShareParams(
                      text: '功课助手分享',
                      files: [XFile(tempPath)],
                    );
                    final result = await SharePlus.instance.share(params);
                    if (result.status == ShareResultStatus.success) {
                      logger.i('分享成功');
                    } else if (result.status == ShareResultStatus.dismissed) {
                      logger.i('Did you not like the pictures?');
                    }
                  },
                  child: const Text(
                    "截图分享",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    final capturedImage = await _captureImage();
                    if (capturedImage.isNotEmpty) {
                      await Pasteboard.writeImage(capturedImage);
                      toastification.show(
                        type: ToastificationType.success,
                        title: const Text('复制成功'),
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    } else {
                      toastification.show(
                        type: ToastificationType.error,
                        title: const Text('截图失败'),
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    }
                  },
                  child: const Text(
                    "复制截图",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                Spacer(),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
