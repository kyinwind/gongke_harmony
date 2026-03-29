import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:gongke/database.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:gongke/comm/audio_tools.dart';
import 'package:gongke/comm/tts_tools.dart';
import 'package:gongke/comm/wakelock_tools.dart';

class BaiChanPlayPage extends StatefulWidget {
  const BaiChanPlayPage({super.key});

  @override
  _BaiChanPlayPageState createState() => _BaiChanPlayPageState();
}

class _BaiChanPlayPageState extends State<BaiChanPlayPage> {
  bool _isInitialized = false; // 添加初始化标记
  late int baichanId;
  BaiChanData? baichan;
  int count = 0;
  bool isPlaying = false;
  bool flag = true;
  int num = 0;
  Timer? _timer;
  String msg = "拜忏中...";
  final TtsTools _ttsTools = TtsTools();
  bool _isAnnouncing = false;

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
    baichan = temp;

    _isInitialized = true;
    if (baichanId > 0 && baichan != null) {
      _announce(baichan!.chanhuiWenStart.toString(), () => _startLoop());
    }
  }

  Future<BaiChanData> _loadBaiChanData(id) async {
    return await (globalDB.select(globalDB.baiChan)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  void _startLoop() async {
    setState(() => isPlaying = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPlaying || _isAnnouncing) return;
      WakelockTools.enable(); //避免息屏
      final currentBaiChan = baichan;
      if (currentBaiChan == null) {
        return;
      }
      if (flag) {
        final int baichanInterval2 = currentBaiChan.baichanInterval2.toInt();
        if (num % baichanInterval2 == 0) {
          setState(() {
            count++;
          });

          if (count <= currentBaiChan.baichanTimes &&
              currentBaiChan.flagOrderNumber) {
            _speakAfterBell("第$count拜");
          }
          num = 0;
          flag = false;
        }
        if (count == currentBaiChan.baichanTimes.toInt() + 1) {
          _speakAfterBell(currentBaiChan.chanhuiWenEnd, onDone: () {
            _stop();
            WakelockTools.disable();
            Navigator.pop(context);
          });
        }
        num++;
      } else {
        if (num % currentBaiChan.baichanInterval1.toInt() == 0) {
          if (currentBaiChan.flagQiShen) {
            _speakAfterBell("起身");
          }
          num = 0;
          flag = true;
        }
        num++;
      }
    });
  }

  Future<void> _announce(String text, VoidCallback onDone) async {
    if (!mounted) {
      return;
    }
    setState(() {
      msg = text;
    });
    _isAnnouncing = true;
    await _ttsTools.speak(text, () {
      _isAnnouncing = false;
      onDone();
    });
  }

  Future<void> _speakAfterBell(String text, {VoidCallback? onDone}) async {
    _isAnnouncing = true;
    await AudioTools.playLocalAsset('mp3/yinqing.wav');
    if (!mounted) {
      return;
    }
    await _announce(text, onDone ?? () {});
  }

  void _stop() async {
    _timer?.cancel();
    _isAnnouncing = false;
    await _ttsTools.stop();
    if (!mounted) return; // ✅ 避免 setState 后报错
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    WakelockTools.disable(); //放开避免息屏
    _timer?.cancel();
    _ttsTools.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (baichan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('拜忏进行中')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final bai = baichan!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('拜忏进行中'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$count / ${bai.baichanTimes.toInt()} \n$msg'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
