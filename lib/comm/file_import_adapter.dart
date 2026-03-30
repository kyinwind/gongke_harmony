import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker_ohos/file_picker_ohos.dart';

class ImportFileRef {
  final String path;
  final String name;
  final String displayPath;
  final Future<Uint8List> Function() readBytes;
  final Future<void> Function(File targetFile) writeTo;

  ImportFileRef({
    required this.path,
    required this.name,
    required this.displayPath,
    required this.readBytes,
    required this.writeTo,
  });
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
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
      withReadStream: false,
    );
    final files = result?.files ?? const <PlatformFile>[];

    return files
        .where((file) => (file.path ?? '').isNotEmpty)
        .map(
          (file) => ImportFileRef(
            path: file.path!,
            name: _normalizeFileName(file.name, file.path!),
            displayPath: _normalizeDisplayPath(file.path!),
            readBytes: () async {
              if (file.bytes != null) {
                return file.bytes!;
              }
              return File(file.path!).readAsBytes();
            },
            writeTo: (targetFile) async {
              final sink = targetFile.openWrite();
              try {
                await sink.addStream(File(file.path!).openRead());
              } finally {
                await sink.close();
              }
            },
          ),
        )
        .toList();
  }

  String _normalizeFileName(String rawName, String rawPath) {
    final candidate =
        rawName.trim().isNotEmpty ? rawName : _lastPathSegment(rawPath);
    final decoded = _decodeUri(candidate);
    return _repairMojibake(decoded);
  }

  String _lastPathSegment(String rawPath) {
    final normalized = _decodeUri(rawPath);
    final segments = normalized.split('/');
    return segments.isEmpty ? normalized : segments.last;
  }

  String _decodeUri(String value) {
    if (!value.contains('%')) {
      return value;
    }
    try {
      return Uri.decodeFull(value);
    } catch (_) {
      return value;
    }
  }

  String _normalizeDisplayPath(String rawPath) {
    final decoded = _decodeUri(rawPath);
    if (decoded.startsWith('file://')) {
      return decoded.replaceFirst('file://', '');
    }
    return decoded;
  }

  String _repairMojibake(String value) {
    if (!_looksMojibake(value)) {
      return value;
    }
    try {
      final repaired = utf8.decode(latin1.encode(value));
      if (_containsChinese(repaired) || !_looksMojibake(repaired)) {
        return repaired;
      }
    } catch (_) {}
    return value;
  }

  bool _looksMojibake(String value) {
    const markers = [
      'Ã',
      'Â',
      'å',
      'ä',
      'ç',
      'é',
      'è',
      'ê',
      'ï',
      'ð',
      'Ñ',
      '�'
    ];
    return markers.any(value.contains);
  }

  bool _containsChinese(String value) {
    return RegExp(r'[\u4e00-\u9fff]').hasMatch(value);
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
