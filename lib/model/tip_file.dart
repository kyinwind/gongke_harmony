import 'dart:convert';
import 'dart:typed_data';

class TipFileFormatException implements Exception {
  const TipFileFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TipBookFileDto {
  const TipBookFileDto({
    this.schemaVersion = 1,
    required this.quotation,
  });

  final int schemaVersion;
  final TipBookDto quotation;

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'quotation': quotation.toJson(),
      };
}

class TipBookDto {
  const TipBookDto({
    this.id,
    required this.name,
    this.remarks = '',
    this.image = '',
    this.version,
    this.productId,
    required this.records,
  });

  final String? id;
  final String name;
  final String remarks;
  final String image;
  final String? version;
  final String? productId;
  final List<TipRecordDto> records;

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'remarks': remarks,
        'image': image,
        if (version != null) 'ver': version,
        if (productId != null) 'productId': productId,
        'records': records.map((record) => record.toJson()).toList(),
      };
}

class TipRecordDto {
  const TipRecordDto({
    this.id,
    required this.content,
    this.isFavorite = false,
    this.completedDate,
    this.comments = '',
    this.tag,
  });

  final String? id;
  final String content;
  final bool isFavorite;
  final DateTime? completedDate;
  final String comments;
  final String? tag;

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'content': content,
        'isShow': completedDate != null,
        'isFavorite': isFavorite,
        // Swift JSONEncoder/JSONDecoder 的 Date 默认格式：自 2001-01-01 UTC
        // 起的秒数。使用该格式保证 Harmony 导出可直接回导 mac。
        'completedDate': completedDate == null
            ? null
            : completedDate!
                    .toUtc()
                    .difference(DateTime.utc(2001))
                    .inMilliseconds /
                1000,
        if (comments.isNotEmpty) 'comments': comments,
        if (tag != null) 'tag': tag,
      };
}

class TipFileCodec {
  const TipFileCodec({
    this.maxFileBytes = 10 * 1024 * 1024,
    this.maxDecodedImageBytes = 2 * 1024 * 1024,
  });

  final int maxFileBytes;
  final int maxDecodedImageBytes;

  TipBookFileDto decodeBytes(Uint8List bytes) {
    if (bytes.length > maxFileBytes) {
      throw TipFileFormatException(
          '开示文件超过 ${maxFileBytes ~/ (1024 * 1024)} MiB 限制');
    }
    String source;
    try {
      source = utf8.decode(bytes);
    } on FormatException {
      throw const TipFileFormatException('开示文件不是有效的 UTF-8 JSON');
    }
    return decode(source);
  }

  TipBookFileDto decode(String source) {
    Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException catch (error) {
      throw TipFileFormatException('JSON 格式错误：${error.message}');
    }
    final rootMap = _asMap(root, r'$');
    final schemaVersion =
        _optionalInt(rootMap['schemaVersion'], r'$.schemaVersion') ?? 1;
    if (schemaVersion < 1 || schemaVersion > 1) {
      throw TipFileFormatException('不支持的开示文件版本：$schemaVersion');
    }
    final quotation = _asMap(rootMap['quotation'], r'$.quotation');
    final name = _requiredString(quotation['name'], r'$.quotation.name').trim();
    if (name.isEmpty) {
      throw const TipFileFormatException(r'$.quotation.name 不能为空');
    }
    final image =
        _optionalString(quotation['image'], r'$.quotation.image') ?? '';
    _validateImage(image);
    final rawRecords = quotation['records'];
    if (rawRecords is! List<Object?>) {
      throw const TipFileFormatException(r'$.quotation.records 必须是数组');
    }
    final records = <TipRecordDto>[];
    for (var index = 0; index < rawRecords.length; index++) {
      final path = r'$.quotation.records[' + index.toString() + ']';
      final record = _asMap(rawRecords[index], path);
      final content =
          _requiredString(record['content'], '$path.content').trim();
      if (content.isEmpty) {
        throw TipFileFormatException('$path.content 不能为空');
      }
      records.add(TipRecordDto(
        id: _stringLike(record['id'], '$path.id'),
        content: content,
        isFavorite:
            _optionalBool(record['isFavorite'], '$path.isFavorite') ?? false,
        completedDate:
            _optionalDate(record['completedDate'], '$path.completedDate'),
        comments: _optionalString(record['comments'], '$path.comments') ?? '',
        tag: _optionalString(record['tag'], '$path.tag'),
      ));
    }
    return TipBookFileDto(
      schemaVersion: schemaVersion,
      quotation: TipBookDto(
        id: _stringLike(quotation['id'], r'$.quotation.id'),
        name: name,
        remarks:
            _optionalString(quotation['remarks'], r'$.quotation.remarks') ?? '',
        image: image,
        version: _stringLike(quotation['ver'], r'$.quotation.ver'),
        productId:
            _stringLike(quotation['productId'], r'$.quotation.productId'),
        records: records,
      ),
    );
  }

  String encode(TipBookFileDto file) =>
      const JsonEncoder.withIndent('  ').convert(file.toJson());

  void _validateImage(String image) {
    if (image.isEmpty) return;
    final payload =
        image.contains(',') ? image.substring(image.indexOf(',') + 1) : image;
    Uint8List decoded;
    try {
      decoded = base64Decode(payload);
    } on FormatException {
      throw const TipFileFormatException(r'$.quotation.image 不是有效的 Base64 图片');
    }
    if (decoded.length > maxDecodedImageBytes) {
      throw TipFileFormatException(
        r'$.quotation.image 解码后超过 ' +
            (maxDecodedImageBytes ~/ (1024 * 1024)).toString() +
            ' MiB 限制',
      );
    }
  }

  Map<String, Object?> _asMap(Object? value, String path) {
    if (value is Map<String, Object?>) return value;
    if (value is Map)
      return value.map((key, value) => MapEntry(key.toString(), value));
    throw TipFileFormatException('$path 必须是对象');
  }

  String _requiredString(Object? value, String path) {
    if (value is String) return value;
    throw TipFileFormatException('$path 必须是字符串');
  }

  String? _optionalString(Object? value, String path) {
    if (value == null) return null;
    if (value is String) return value;
    throw TipFileFormatException('$path 必须是字符串');
  }

  String? _stringLike(Object? value, String path) {
    if (value == null) return null;
    if (value is String || value is num) return value.toString();
    throw TipFileFormatException('$path 必须是字符串或数字');
  }

  int? _optionalInt(Object? value, String path) {
    if (value == null) return null;
    if (value is int) return value;
    throw TipFileFormatException('$path 必须是整数');
  }

  bool? _optionalBool(Object? value, String path) {
    if (value == null) return null;
    if (value is bool) return value;
    throw TipFileFormatException('$path 必须是布尔值');
  }

  DateTime? _optionalDate(Object? value, String path) {
    if (value == null || value == '') return null;
    if (value is num) {
      if (!value.isFinite) throw TipFileFormatException('$path 不是有效日期');
      final seconds = value.toDouble();
      if (seconds.abs() > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.round(),
            isUtc: true);
      }
      // mac 版 Codable 使用 Apple Reference Date（2001-01-01）。
      return DateTime.utc(2001)
          .add(Duration(milliseconds: (seconds * 1000).round()));
    }
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) return date;
    }
    throw TipFileFormatException('$path 不是有效的 ISO 8601/Swift Codable 日期');
  }
}
