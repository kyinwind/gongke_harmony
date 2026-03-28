import 'package:flutter/material.dart';
import 'dart:async';
import '../../database.dart';
import '../../main.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/pub_tools.dart';
import '../../comm/audio_tools.dart';
import '../../comm/wakelock_tools.dart';

class DaZuoPage extends StatefulWidget {
  const DaZuoPage({super.key});

  @override
  State<DaZuoPage> createState() => _DaZuoPageState();
}

class _DaZuoPageState extends State<DaZuoPage> {
  Map<String, dynamic>? _routeParams;
  GongKeItemData? gki; //根据传入的参数获取功课项
  bool isLoaded = false; //是否已经载入数据，如果已经载入就不需要重复载入
  bool isGoingon = false;
  int totalMinutes = 0;
  int loopIndex = 0;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get route arguments
    if (!isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['gongkeitem'] is GongKeItemData) {
        gki = args['gongkeitem'] as GongKeItemData;
        isLoaded = true;
      }
      print(gki.toString());
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void startTimer(GongKeItemData gki) {
    loopIndex = totalMinutes * 60;
    if (loopIndex == 0) loopIndex = gki.cnt * 60;

    playYinqingSequence(() {
      setState(() => isGoingon = true);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!isGoingon) {
          timer.cancel();
          return;
        }
        setState(() {
          if (loopIndex > 0) {
            loopIndex--;
            WakelockTools.enable();
          } else {
            isGoingon = false;
            playYinqingSequence(() {
              // if (totalMinutes >= gki.cnt) {
              //   makeComplete(gki);
              // }
            });
            timer.cancel();
            WakelockTools.disable();
          }
        });
      });
    });
  }

  void makeComplete(GongKeItemData gki) {
    globalDB.managers.gongKeItem
        .filter((item) => item.id.equals(gki.id))
        .update((o) => o(isComplete: const Value(true)));
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() => isGoingon = false);
  }

  void playYinqingSequence(VoidCallback onFinished) {
    int count = 0;

    void playNext() {
      if (count < 3) {
        print("Yinqing sound ${count + 1}");
        AudioTools.playLocalAsset('mp3/yinqing.wav', onComplete: playNext);
        count++;
      } else {
        onFinished();
      }
    }

    playNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioTools.stop();
    WakelockTools.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("打坐计时")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("功课内容"),
              subtitle: Text(
                "${gki!.name} ${gki!.cnt}"
                " ${getDanWei(gki!.gongketype)}",
              ),
            ),
            Divider(),
            ListTile(
              title: Text("请设置打坐时间:"),
              subtitle: DaZuoTimeView(
                initialMinutes: gki!.cnt ?? 0,
                onChanged: (val) {
                  setState(() {
                    totalMinutes = val;
                    loopIndex = val * 60;
                  });
                },
                isDisabled: isGoingon,
              ),
            ),
            Divider(),
            ListTile(
              title: Text("点击按钮开始计时"),
              subtitle: Text("打坐开始与结束会敲引磬提醒。入静3下，出静3下。"),
            ),
            Center(
              child: Text(
                formatTime(loopIndex),
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: AppButtonStyle.primaryButton,
                  onPressed: isGoingon ? stopTimer : () => startTimer(gki!),
                  child: Text(isGoingon ? "结束" : "开始"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DaZuoTimeView extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;
  final bool isDisabled;

  DaZuoTimeView({
    required this.initialMinutes,
    required this.onChanged,
    required this.isDisabled,
  });

  @override
  _DaZuoTimeViewState createState() => _DaZuoTimeViewState();
}

class _DaZuoTimeViewState extends State<DaZuoTimeView> {
  double _gongkeDaZuoTime = 60;

  @override
  void initState() {
    super.initState();
    _gongkeDaZuoTime = widget.initialMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${_gongkeDaZuoTime.toStringAsFixed(1)} 分钟",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Slider(
          value: _gongkeDaZuoTime,
          min: 10,
          max: 600,
          divisions: 59,
          label: _gongkeDaZuoTime.toStringAsFixed(0),
          onChanged: widget.isDisabled
              ? null
              : (val) {
                  setState(() => _gongkeDaZuoTime = val);
                  widget.onChanged(val.toInt());
                },
        ),
      ],
    );
  }
}
