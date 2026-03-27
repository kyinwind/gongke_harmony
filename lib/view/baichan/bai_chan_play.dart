import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gongke/main.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gongke/database.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:gongke/comm/audio_tools.dart';

class BaiChanPlayPage extends StatefulWidget {
  const BaiChanPlayPage({super.key});

  @override
  _BaiChanPlayPageState createState() => _BaiChanPlayPageState();
}

class _BaiChanPlayPageState extends State<BaiChanPlayPage> {
  bool _isInitialized = false; // 添加初始化标记
  late int baichanId;
  late BaiChanData baichan;
  int count = 0;
  bool isPlaying = false;
  bool flag = true;
  int num = 0;
  Timer? _timer;
  String msg = "拜忏中...";
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      return;
    }
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    baichanId = args['baichanId'] as int;
    BaiChanData? temp;
    temp = args['baichan'] as BaiChanData?;
    if (temp != null) {
      baichan = temp;
    }

    _isInitialized = true;
    if (baichanId > 0 && baichan != null) {
      _speak(baichan.chanhuiWenStart.toString(), () => _startLoop());
    }
  }

  Future<BaiChanData> _loadBaiChanData(id) async {
    return await globalDB.managers.baiChan
        .filter((f) => f.id.equals(id))
        .getSingle();
  }

  void _startLoop() async {
    setState(() => isPlaying = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPlaying) return;
      WakelockPlus.enable(); //避免息屏
      if (flag) {
        final int baichanInterval2 = baichan.baichanInterval2.toInt();
        if (num % baichanInterval2 == 0) {
          setState(() {
            count++;
          });

          if (count <= baichan.baichanTimes && baichan.flagOrderNumber) {
            AudioTools.playLocalAsset('mp3/yinqing.wav').then((_) {
              _speak("第$count 拜", () {});
            });
          }
          num = 0;
          flag = false;
        }
        if (count == baichan.baichanTimes.toInt() + 1) {
          AudioTools.playLocalAsset('mp3/yinqing.wav').then((_) {
            _speak(baichan.chanhuiWenEnd, () {
              _stop();
              WakelockPlus.disable();
              Navigator.pop(context);
            });
          });
        }
        num++;
      } else {
        if (num % baichan.baichanInterval1.toInt() == 0) {
          if (baichan.flagQiShen) {
            AudioTools.playLocalAsset('mp3/yinqing.wav').then((_) {
              _speak("起身", () {});
            });
          }
          num = 0;
          flag = true;
        }
        num++;
      }
    });
  }

  Future<void> _speak(String text, VoidCallback onDone) async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      onDone();
    });
  }

  void _stop() async {
    _timer?.cancel();
    await flutterTts.stop();
    if (!mounted) return; // ✅ 避免 setState 后报错
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    WakelockPlus.disable(); //放开避免息屏
    _timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (baichan == null) {
      return Scaffold(
        appBar: AppBar(title: Text('拜忏进行中')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final bai = baichan;
    return Scaffold(
      appBar: AppBar(
        title: Text('拜忏进行中'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: isPlaying ? _stop : _startLoop,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  getFoPuSaImagePath(bai.image),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text('$count / ${bai.baichanTimes.toInt()} $msg'),
            ],
          ),
        ),
      ),
    );
  }
}
