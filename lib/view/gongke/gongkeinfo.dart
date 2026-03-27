import 'package:flutter/material.dart';

class GongKeInfoWidget extends StatelessWidget {
  const GongKeInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('另一个页面'),
      ),
      body: const Center(
        child: Text('这是点击后打开的页面'),
      ),
    );
  }
}
