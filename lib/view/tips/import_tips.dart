import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ImportTipPage extends StatelessWidget {
  const ImportTipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入开示录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '选择导入方式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).padding(bottom: 20),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('从文件导入'),
              onTap: () {
                // 实现文件导入逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('从云端导入'),
              onTap: () {
                // 实现云端导入逻辑
              },
            ),
          ],
        ),
      ),
    );
  }
}