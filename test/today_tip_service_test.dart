import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/today_tip_service.dart';

void main() {
  test('sequential mode advances by local calendar day and wraps', () {
    final start = DateTime(2026, 8, 15, 20);
    expect(
      TodayTipService.selectIndex(
        length: 3,
        now: DateTime(2026, 8, 15, 1),
        startDate: start,
        mode: TodayTipMode.sequential,
      ),
      0,
    );
    expect(
      TodayTipService.selectIndex(
        length: 3,
        now: DateTime(2026, 8, 18),
        startDate: start,
        mode: TodayTipMode.sequential,
      ),
      0,
    );
  });

  test('sequential mode handles dates before start date', () {
    final index = TodayTipService.selectIndex(
      length: 5,
      now: DateTime(2026, 8, 14),
      startDate: DateTime(2026, 8, 15),
      mode: TodayTipMode.sequential,
    );
    expect(index, 4);
  });

  test('random mode is stable during the same day and scope', () {
    final first = TodayTipService.selectIndex(
      length: 97,
      now: DateTime(2026, 8, 15, 1),
      startDate: DateTime(2026),
      mode: TodayTipMode.random,
      seedScope: 'card-1',
    );
    final second = TodayTipService.selectIndex(
      length: 97,
      now: DateTime(2026, 8, 15, 23),
      startDate: DateTime(2020),
      mode: TodayTipMode.random,
      seedScope: 'card-1',
    );
    expect(second, first);
  });
}
