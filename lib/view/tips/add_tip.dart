import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:styled_widget/styled_widget.dart';
//import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import '../../comm/pub_tools.dart';

class AddTipPage extends StatefulWidget {
  const AddTipPage({super.key});

  @override
  State<AddTipPage> createState() => _AddTipPageState();
}

class _AddTipPageState extends State<AddTipPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _base64Image;
  late String acttype;
  late int recordId;
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
    final data = await globalDB.managers.tipBook
        .filter((f) => f.id(recordId))
        .getSingle();
    setState(() {
      _nameController.text = data.name;
      _remarksController.text = data.remarks ?? '';
      _base64Image = data.image;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //File? selectedImage;
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // 处理图片大小
      final processedImage = await _processImage(imageFile);
      setState(() {
        //selectedImage = processedImage;
        _base64Image = base64Encode(processedImage.readAsBytesSync());
      });
    }
  }

  Future<File> _processImage(File imageFile) async {
    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

    // 如果图片宽或高大于1024，则等比例缩小
    if (decodedImage.width > 1024 || decodedImage.height > 1024) {
      final scale =
          1024 /
          (decodedImage.width > decodedImage.height
              ? decodedImage.width
              : decodedImage.height);

      final newWidth = (decodedImage.width * scale).round();
      final newHeight = (decodedImage.height * scale).round();

      // 这里简化处理，实际应用中可能需要更复杂的图片缩放逻辑
      return imageFile; // 实际应用中应返回缩放后的图片
    }

    return imageFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (acttype == 'new') {
        await globalDB.managers.tipBook.create(
          (o) => o(
            name: _nameController.text,
            remarks: Value(_remarksController.text),
            image: _base64Image ?? '',
          ),
          mode: InsertMode.replace,
        );
      } else {
        await globalDB.managers.tipBook
            .filter((f) => f.id(recordId))
            .update(
              (o) => o(
                name: Value(_nameController.text),
                remarks: Value(_remarksController.text),
                image: Value(_base64Image ?? ''),
              ),
            );
      }
      // 返回上一级路由
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(acttype == 'new' ? '新增开示录' : '修改开示录'),
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
                onPressed: _pickImage,
                child: const Text('选择图片'),
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
    );
  }
}
