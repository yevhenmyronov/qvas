import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/providers/history_providers.dart';

/// Місяць Екрана 2 перегортається разом із календарем — але тільки
/// якщо людина дивилась на поточний (знайдено догфудингом 2026-10-02:
/// першого числа екран відкривався на минулому місяці).
void main() {
  late MonthKey today;
  late ProviderContainer container;

  setUp(() {
    today = const MonthKey(2026, 9);
    container = ProviderContainer(overrides: [
      selectedMonthProvider
          .overrideWith(() => SelectedMonthController(now: () => today)),
    ]);
    addTearDown(container.dispose);
  });

  MonthKey shown() => container.read(selectedMonthProvider);
  SelectedMonthController ctrl() =>
      container.read(selectedMonthProvider.notifier);

  test('поточний місяць перегортається після межі', () {
    expect(shown(), const MonthKey(2026, 9));
    today = const MonthKey(2026, 10);
    ctrl().sync();
    expect(shown(), const MonthKey(2026, 10));
  });

  test('без межі місяця sync нічого не міняє', () {
    ctrl().show(const MonthKey(2026, 7));
    ctrl().sync();
    expect(shown(), const MonthKey(2026, 7));
  });

  test('місяць, обраний стрілками, не чіпається', () {
    ctrl().show(const MonthKey(2026, 7));
    today = const MonthKey(2026, 10);
    ctrl().sync();
    expect(shown(), const MonthKey(2026, 7));
  });

  test('відкриття екрана повертає на поточний', () {
    ctrl().show(const MonthKey(2026, 7));
    today = const MonthKey(2026, 10);
    ctrl().showCurrent();
    expect(shown(), const MonthKey(2026, 10));
  });

  test('межа року', () {
    today = const MonthKey(2026, 12);
    ctrl().showCurrent();
    today = const MonthKey(2027, 1);
    ctrl().sync();
    expect(shown(), const MonthKey(2027, 1));
  });
}
