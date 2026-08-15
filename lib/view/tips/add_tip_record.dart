import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../database.dart';
import '../../comm/pub_tools.dart';

class AddTipRecordPage extends StatefulWidget {
  const AddTipRecordPage({super.key});

  @override
  State<AddTipRecordPage> createState() => _AddTipRecordPageState();
}

class _AddTipRecordPageState extends State<AddTipRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _commentsController = TextEditingController();
  late int bookId; // 默认值，实际使用时可能需要从路由参数获取
  late String acttype;
  int? recordId;
  bool _loadedRecord = false;

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
      recordId = args['recordId'] as int?;
      if (acttype == 'mod' && recordId != null && !_loadedRecord) {
        _loadedRecord = true;
        _loadRecord();
      }
    }
  }

  Future<void> _loadRecord() async {
    final record = await (globalDB.select(globalDB.tipRecord)
          ..where((table) => table.id.equals(recordId!)))
        .getSingleOrNull();
    if (record == null || !mounted) return;
    setState(() {
      _contentController.text = record.content;
      _commentsController.text = record.comments;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (acttype == 'new') {
        final maxSortOrder = await globalDB.customSelect(
          'SELECT MAX(sort_order) AS max_sort_order FROM tip_record WHERE book_id = ?',
          variables: [Variable.withInt(bookId)],
        ).getSingle();
        final nextSortOrder =
            (maxSortOrder.readNullable<int>('max_sort_order') ?? -1) + 1;
        await globalDB.into(globalDB.tipRecord).insert(
              TipRecordCompanion.insert(
                content: _contentController.text.trim(),
                bookId: bookId,
                comments: Value(_commentsController.text.trim()),
                sortOrder: Value(nextSortOrder),
              ),
            );
      } else if (recordId != null) {
        await globalDB.managers.tipRecord
            .filter((filter) => filter.id(recordId!))
            .update(
              (row) => row(
                content: Value(_contentController.text.trim()),
                comments: Value(_commentsController.text.trim()),
              ),
            );
      }
      if (!mounted) return; // 添加这行检查
      // 返回上一级路由
      Navigator.of(context).pop(true);
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
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: '评论（可选）',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 5,
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
