import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/tts_tools.dart';

void main() {
  test('splitText keeps short text in one chunk', () {
    expect(TtsTools.splitText('  一句开示。  '), ['一句开示。']);
  });

  test('splitText prefers punctuation and preserves all content', () {
    const text = '甲乙丙。丁戊己庚辛。';
    final chunks = TtsTools.splitText(text, limit: 5);

    expect(chunks, ['甲乙丙。', '丁戊己庚辛', '。']);
    expect(chunks.join(), text);
    expect(chunks.every((chunk) => chunk.length <= 5), isTrue);
  });

  test('splitText hard-splits text without punctuation', () {
    final chunks = TtsTools.splitText('123456789', limit: 4);

    expect(chunks, ['1234', '5678', '9']);
  });
}
