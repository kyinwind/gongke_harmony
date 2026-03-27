import 'package:flutter/material.dart';

class ShareCardPage extends StatefulWidget {
  const ShareCardPage({super.key});

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分享功课')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '鸿蒙迁移首版已暂时关闭分享功能，后续会在平台能力稳定后再恢复。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
