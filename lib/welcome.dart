import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../comm/pub_tools.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onFinish;
  const WelcomePage({super.key, required this.onFinish});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final helpSlides = getHelpSlidesForWidth(MediaQuery.of(context).size.width);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: helpSlides.length,
                itemBuilder: (context, i, realIdx) {
                  final item = helpSlides[i];
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
                helpSlides.length,
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
                    onPressed:
                        _current > 0 ? () => _controller.previousPage() : null,
                    child: const Text('上一页'),
                  ),
                  TextButton(
                    onPressed: widget.onFinish,
                    child: const Text('跳过'),
                  ),
                  TextButton(
                    onPressed: _current < helpSlides.length - 1
                        ? () => _controller.nextPage()
                        : widget.onFinish,
                    child: Text(
                      _current < helpSlides.length - 1 ? '下一页' : '进入应用',
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
