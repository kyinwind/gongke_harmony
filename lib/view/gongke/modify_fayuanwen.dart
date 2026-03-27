import 'package:flutter/material.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import '../../main.dart';

class ModifyFaYuanWenPage extends StatefulWidget {
  const ModifyFaYuanWenPage({super.key});

  @override
  State<ModifyFaYuanWenPage> createState() => _ModifyFaYuanWenPageState();
}

class _ModifyFaYuanWenPageState extends State<ModifyFaYuanWenPage> {
  final TextEditingController _textController = TextEditingController();
  FaYuanData? _fayuanData;
  late int fayuanId;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    fayuanId = args['fayuanId'] as int;
    _loadFayuan();
  }

  Future<void> _loadFayuan() async {
    final fayuan = await globalDB.managers.faYuan
        .filter((f) => f.id.equals(fayuanId))
        .getSingleOrNull();

    setState(() {
      _fayuanData = fayuan;
      _textController.text = fayuan?.fayuanwen ?? '';
    });
  }

  Future<void> _saveFayuan() async {
    if (_fayuanData != null) {
      await globalDB.managers.faYuan
          .filter((f) => f.id.equals(fayuanId))
          .update((o) => o(fayuanwen: Value(_textController.text)));

      // 添加 mounted 检查
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    // 确保在销毁时清理键盘焦点
    FocusManager.instance.primaryFocus?.unfocus();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改发愿文'),
        actions: [TextButton(onPressed: _saveFayuan, child: const Text('保存'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                maxLines: null,
                expands: true, // 添加这行，允许文本框展开
                textAlignVertical: TextAlignVertical.top, // 添加这行，文本从顶部开始
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请修改发愿文内容',
                  contentPadding: EdgeInsets.all(16), // 添加内边距
                ),
                scrollPhysics: const ClampingScrollPhysics(), // 添加这行，改善滚动体验
                enableInteractiveSelection: true, // 添加这行，启用文本选择
              ),
            ),
          ],
        ),
      ),
    );
  }
}
