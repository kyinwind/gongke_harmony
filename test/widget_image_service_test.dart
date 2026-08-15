import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/widget_image_service.dart';

void main() {
  test('stableHash is deterministic and content-sensitive', () {
    final first = WidgetImageService.stableHash(Uint8List.fromList([1, 2, 3]));
    expect(WidgetImageService.stableHash(Uint8List.fromList([1, 2, 3])), first);
    expect(WidgetImageService.stableHash(Uint8List.fromList([1, 2, 4])),
        isNot(first));
  });
}
