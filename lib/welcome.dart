import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../comm/pub_tools.dart';

final List<Map<String, String>> help_slides = [
  {
    'image': 'assets/help/101.png',
    'title': '首页',
    'description': '发愿功课，功课完成日历一目了然',
  },
  {
    'image': 'assets/help/102.png',
    'title': '发愿向导',
    'description': '跟随发愿向导，制定功课计划。',
  },
  {
    'image': 'assets/help/103.png',
    'title': '完成功课记录',
    'description': '点击日历日期，完成当天功课。',
  },
  {
    'image': 'assets/help/104.png',
    'title': '双页显示经书',
    'description': '使用空格，回车翻页，使用上下键切换页。',
  },
  {
    'image': 'assets/help/105.png',
    'title': '完成功课小工具-功课计数',
    'description': '对于念咒类功课，提供计数小工具。\n同样对于念佛、打坐提供电子木鱼和打坐计时工具。',
  },
  {
    'image': 'assets/help/106.png',
    'title': '双页显示善书，单页显示可以听书',
    'description': '可以记住上一次读到的页码，下次打开时直接从上次页码开始。\n单页显示时可以听书。',
  },
  {
    'image': 'assets/help/107.png',
    'title': '大德开示',
    'description': '每天一句大德开示，勉励自己精进修行。',
  },
  {
    'image': 'assets/help/108.png',
    'title': '拜忏',
    'description': '根据自己体力和发愿，自定义人声引导拜忏，自净其意。',
  },
  {
    'image': 'assets/help/109.png',
    'title': '文件导入',
    'description': '本app不包含经书、善书和开示文件，需要用户自己导入使用，请关注app技术支持网站。',
  },
];

class WelcomePage extends StatefulWidget {
  final VoidCallback onFinish;
  const WelcomePage({super.key, required this.onFinish});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  List<Map<String, String>> help_slides = Platform.isWindows
      ? help_slides_windows
      : help_slides_android;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: help_slides.length,
                itemBuilder: (context, i, realIdx) {
                  final item = help_slides[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(item['image']!, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          item['description'] ?? '',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                help_slides.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == i ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _current > 0
                        ? () => _controller.previousPage()
                        : null,
                    child: const Text('上一页'),
                  ),
                  TextButton(
                    onPressed: widget.onFinish,
                    child: const Text('跳过'),
                  ),
                  TextButton(
                    onPressed: _current < help_slides.length - 1
                        ? () => _controller.nextPage()
                        : widget.onFinish,
                    child: Text(
                      _current < help_slides.length - 1 ? '下一页' : '进入应用',
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
}
