import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/pub_tools.dart';

class AddTipRecordPage extends StatefulWidget {
  const AddTipRecordPage({super.key});

  @override
  State<AddTipRecordPage> createState() => _AddTipRecordPageState();
}

class _AddTipRecordPageState extends State<AddTipRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  late int bookId; // 默认值，实际使用时可能需要从路由参数获取
  late String acttype;

  @override
  void initState() {
    super.initState();
    acttype = 'new'; // 设置默认值
    bookId = 0; // 默认值，实际使用时可能需要从路由参数获取
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['bookId'] != null) {
      acttype = args['acttype'];
      bookId = args['bookId'];
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (acttype == 'new') {
        await globalDB.managers.tipRecord.create(
          (o) => o(content: _contentController.text, bookId: bookId),
          mode: InsertMode.replace,
        );
      }
      if (!mounted) return; // 添加这行检查
      // 返回上一级路由
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(acttype == 'new' ? '新增开示' : '修改开示'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _submitForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '请输入开示内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // null表示无限行数
                minLines: 5, // 最小显示3行
                keyboardType: TextInputType.multiline, // 多行文本键盘类型
                textInputAction: TextInputAction.newline, // 回车键变成换行
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入开示内容';
                  }
                  return null;
                },
              ).padding(bottom: 16),
              ElevatedButton(
                style: AppButtonStyle.primaryButton,
                onPressed: _submitForm,
                child: const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
