import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/model/tip_file.dart';

void main() {
  const codec = TipFileCodec();

  test('decodes legacy mac tip file and preserves record state', () {
    final file = codec.decode('''
      {"quotation":{"name":" 测试开示 ","remarks":"来源","image":"",
      "records":[{"id":"1","content":" 一句开示 ","isFavorite":true,
      "completedDate":"2026-08-15T08:00:00Z","comments":"备注"}]}}
    ''');

    expect(file.schemaVersion, 1);
    expect(file.quotation.name, '测试开示');
    expect(file.quotation.records.single.id, '1');
    expect(file.quotation.records.single.content, '一句开示');
    expect(file.quotation.records.single.isFavorite, isTrue);
    expect(file.quotation.records.single.completedDate, isNotNull);
    expect(file.quotation.records.single.comments, '备注');
  });

  test('round trip keeps supported fields', () {
    final original = TipBookFileDto(
      quotation: TipBookDto(
        id: 'book-1',
        name: '开示录',
        version: '2',
        records: const [
          TipRecordDto(id: 'r1', content: '正文', isFavorite: true, tag: '净土'),
        ],
      ),
    );
    final decoded = codec.decode(codec.encode(original));

    expect(decoded.quotation.id, 'book-1');
    expect(decoded.quotation.version, '2');
    expect(decoded.quotation.records.single.tag, '净土');
    expect(decoded.quotation.records.single.isFavorite, isTrue);
  });

  test('matches mac Swift Codable wrapper and reference-date seconds', () {
    final file = codec.decode('''
      {"quotation":{"name":"mac 导出","remarks":"","image":"","ver":"2026-08-15",
      "records":[{"id":"r1","content":"正文","isFavorite":true,
      "completedDate":808099200}]}}
    ''');
    expect(
      file.quotation.records.single.completedDate,
      DateTime.utc(2001).add(const Duration(seconds: 808099200)),
    );

    final encoded = jsonDecode(codec.encode(file)) as Map<String, dynamic>;
    final quotation = encoded['quotation'] as Map<String, dynamic>;
    final record =
        (quotation['records'] as List).single as Map<String, dynamic>;
    expect(record['completedDate'], isA<num>());
    expect(record['completedDate'], 808099200);
  });

  test('rejects invalid required fields and image data', () {
    expect(
      () => codec.decode('{"quotation":{"name":"","records":[]}}'),
      throwsA(isA<TipFileFormatException>()),
    );
    expect(
      () => codec.decode(
        '{"quotation":{"name":"a","image":"not-base64!","records":[]}}',
      ),
      throwsA(isA<TipFileFormatException>()),
    );
  });

  test('rejects oversized input before decoding', () {
    const smallCodec = TipFileCodec(maxFileBytes: 2);
    expect(
      () => smallCodec.decodeBytes(Uint8List.fromList(utf8.encode('{}x'))),
      throwsA(isA<TipFileFormatException>()),
    );
  });
}
