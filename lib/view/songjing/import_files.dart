import 'package:flutter/material.dart';

import '../../comm/file_import_adapter.dart';
import '../../comm/import_service.dart';
import '../../comm/platform_tools.dart';
import '../../comm/pub_tools.dart';

class ImportFilesPage extends StatefulWidget {
  const ImportFilesPage({super.key});

  @override
  State<ImportFilesPage> createState() => _ImportFilesPageState();
}

class _ImportFilesPageState extends State<ImportFilesPage> {
  final FileImportAdapter _fileImportAdapter = const FileImportAdapter();
  final ImportService _importService = const ImportService();

  String _jingshuType = '';
  List<ImportFileRef> _selectedFiles = [];
  String _title = '';
  String _content = '';
  bool _isImporting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      _jingshuType = args['jingshutype'];
      switch (_jingshuType) {
        case 'jingshu':
          _title = '导入经书文件';
          _content = '请选择需要导入的经书 PDF 文件';
          break;
        case 'shanshu':
          _title = '导入善书文件';
          _content = '请选择需要导入的善书 PDF 文件';
          break;
        case 'kaishi':
          _title = '导入开示文件';
          _content = '请选择需要导入的开示 JSON 文件';
          break;
        default:
      }
    } catch (e) {
      debugPrint('didChangeDependencies error: $e');
    }
  }

  Future<void> _selectFiles() async {
    final allowedExtensions = _jingshuType == 'kaishi'
        ? const ['json']
        : const ['pdf'];
    final selected = await _fileImportAdapter.pickImportFiles(
      allowedExtensions: allowedExtensions,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedFiles = selected;
    });
  }

  Future<void> _confirmImport() async {
    if (_selectedFiles.isEmpty || _isImporting) {
      return;
    }

    setState(() {
      _isImporting = true;
    });
    try {
      final count = await _importService.importFiles(
        importType: _jingshuType,
        files: _selectedFiles,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导入完成，共导入$count 个文件')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导入失败：$e')));
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canImport = PlatformUtils.supportsFileImport;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title),
              Text(_content, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!canImport)
                const Text('当前平台暂不支持文件导入')
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('已选择文件数: ${_selectedFiles.length}'),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_open),
                      label: const Text('选择文件'),
                      onPressed: _selectFiles,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (_selectedFiles.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final selectedFile = _selectedFiles[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(
                          selectedFile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          selectedFile.path,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              if (canImport)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: AppButtonStyle.primaryButton,
                      onPressed: _selectedFiles.isEmpty || _isImporting
                          ? null
                          : _confirmImport,
                      child: Text(_isImporting ? '导入中...' : '确定导入'),
                    ),
                    ElevatedButton(
                      style: AppButtonStyle.primaryButton,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('退出'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
