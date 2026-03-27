import 'package:file_selector/file_selector.dart';

class ImportFileRef {
  final String path;
  final String name;

  const ImportFileRef({required this.path, required this.name});
}

abstract class FileSelectionGateway {
  const FileSelectionGateway();

  Future<List<ImportFileRef>> pickFiles({
    required List<String> allowedExtensions,
    bool allowMultiple,
  });
}

class FileSelectorSelectionGateway implements FileSelectionGateway {
  const FileSelectorSelectionGateway();

  @override
  Future<List<ImportFileRef>> pickFiles({
    required List<String> allowedExtensions,
    bool allowMultiple = true,
  }) async {
    final typeGroup = XTypeGroup(
      label: 'import_files',
      extensions: allowedExtensions,
    );
    final List<XFile> files;
    if (allowMultiple) {
      files = await openFiles(
        acceptedTypeGroups: [typeGroup],
        confirmButtonText: '选择',
      );
    } else {
      final file = await openFile(
        acceptedTypeGroups: [typeGroup],
        confirmButtonText: '选择',
      );
      files = file == null ? const [] : [file];
    }

    return files
        .where((file) => file.path.isNotEmpty)
        .map((file) => ImportFileRef(path: file.path, name: file.name))
        .toList();
  }
}

class FileImportAdapter {
  final FileSelectionGateway gateway;

  const FileImportAdapter({
    this.gateway = const FileSelectorSelectionGateway(),
  });

  Future<List<ImportFileRef>> pickImportFiles({
    required List<String> allowedExtensions,
    bool allowMultiple = true,
  }) {
    return gateway.pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );
  }
}
