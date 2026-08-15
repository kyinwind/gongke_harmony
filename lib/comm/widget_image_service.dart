import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class WidgetImageService {
  const WidgetImageService();

  Future<String?> cacheThumbnail(String base64Image) async {
    if (base64Image.trim().isEmpty) return null;
    try {
      final original = base64Decode(base64Image);
      final hash = stableHash(original);
      final root = Directory(
          path.join((await getTemporaryDirectory()).path, 'widget_images'));
      await root.create(recursive: true);
      final target = File(path.join(root.path, '$hash.jpg'));
      if (!await target.exists()) {
        final compressed = await FlutterImageCompress.compressWithList(
          original,
          minWidth: 480,
          minHeight: 480,
          quality: 78,
          format: CompressFormat.jpeg,
        );
        if (compressed.isEmpty) return null;
        await target.writeAsBytes(compressed, flush: true);
      }
      await _clean(root, keepName: path.basename(target.path));
      return target.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clean(Directory root, {required String keepName}) async {
    final files =
        await root.list().where((item) => item is File).cast<File>().toList();
    for (final file in files) {
      if (path.basename(file.path) != keepName) {
        await file.delete();
      }
    }
  }

  static String stableHash(Uint8List bytes) {
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
