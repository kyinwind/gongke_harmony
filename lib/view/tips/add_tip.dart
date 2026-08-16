import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import '../../comm/file_import_adapter.dart';
import '../../comm/pub_tools.dart';
import '../../comm/widget_snapshot_service.dart';

class AddTipPage extends StatefulWidget {
  const AddTipPage({super.key});

  @override
  State<AddTipPage> createState() => _AddTipPageState();
}

class _AddTipPageState extends State<AddTipPage> {
  static const _fileAdapter = FileImportAdapter();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _base64Image;
  late String acttype;
  late int recordId;
  bool _isPickingImage = false;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    acttype = 'new'; // 设置默认值
    // 不能在initState中直接访问context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      acttype = args['acttype'];
      recordId = args['id'];
      _loadData();
    }
    if (_base64Image == null || _base64Image == '') {
      _loadDefaultImage();
    }
  }

  Future<void> _loadDefaultImage() async {
    try {
      final ByteData byteData = await rootBundle.load(
        'assets/images/jingshu.png',
      );
      final Uint8List bytes = byteData.buffer.asUint8List();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    } catch (e) {
      debugPrint('加载默认图标失败: $e');
      // 可以在这里设置一个默认的base64图片
    }
  }

  Future<void> _loadData() async {
    final data = await (globalDB.select(globalDB.tipBook)
          ..where((tbl) => tbl.id.equals(recordId)))
        .getSingle();
    setState(() {
      _nameController.text = data.name;
      _remarksController.text = data.remarks ?? '';
      _base64Image = data.image;
    });
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final files = await _fileAdapter.pickImportFiles(
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        allowMultiple: false,
      );
      if (files.isEmpty) return;
      final bytes = await files.single.readBytes();
      if (bytes.isEmpty) throw const FormatException('所选图片内容为空');
      if (mounted) setState(() => _base64Image = base64Encode(bytes));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败：$error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final name = _nameController.text.trim();
      if (acttype == 'new') {
        await globalDB.into(globalDB.tipBook).insert(
              TipBookCompanion.insert(
                name: name,
                remarks: Value(_remarksController.text.trim()),
                image: _base64Image ?? '',
                createDateTime: Value(now),
                updatedDateTime: Value(now),
              ),
            );
      } else {
        await globalDB.managers.tipBook.filter((f) => f.id(recordId)).update(
              (o) => o(
                name: Value(name),
                remarks: Value(_remarksController.text.trim()),
                image: Value(_base64Image ?? ''),
                updatedDateTime: Value(now),
              ),
            );
      }
      try {
        await WidgetSnapshotService(globalDB).syncAll();
      } catch (error) {
        debugPrint('开示录已保存，但同步卡片失败：$error');
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(acttype == 'new' ? '新增开示录' : '修改开示录'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入名称';
                    }
                    return null;
                  },
                ).padding(bottom: 16),
                TextFormField(
                  controller: _remarksController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ).padding(bottom: 16),
                ElevatedButton(
                  style: AppButtonStyle.primaryButton,
                  onPressed: _isPickingImage ? null : _pickImage,
                  child: Text(_isPickingImage ? '选择中…' : '选择图片'),
                ),
                if (_base64Image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Image.memory(
                      base64Decode(_base64Image!),
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
