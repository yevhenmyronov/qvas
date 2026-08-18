import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/gen/app_localizations.dart';
import 'models/currency.dart';
import 'providers/category_providers.dart';
import 'providers/core_providers.dart';
import 'providers/input_providers.dart';
import 'providers/locale_providers.dart';
import 'services/input_snapshot_store.dart';
import 'theme/tokens.dart';
import 'ui/input/input_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Edge-to-edge обов'язковий з Android 15 (тех. спека п.10).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: QvasApp()));
}

/// Поки налаштування не прочитані — показуємо пад (перший кадр не чекає
/// на базу, тех. спека п.6). Новий користувач побачить онбординг, щойно
/// стане відомо, що він новий.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings != null && !settings.onboardingDone) {
      return const OnboardingScreen();
    }
    return const InputScreen();
  }
}

/// Стек маршрутів, який веде сам застосунок.
///
/// Потрібен рівно для одного: [NavigatorState.removeRoute] прибирає
/// маршрут миттєво, але вимагає сам об'єкт маршруту, а Navigator свій
/// стек назовні не віддає. Спостерігач — єдиний спосіб його мати.
///
/// Шторки сюди теж потрапляють, і це навмисно: якщо застосунок згорнули
/// з відкритою шторкою, після довгої паузи вона має зникнути разом з
/// усім іншим. `removeRoute` завершує майбутнє маршруту, тож лічильник
/// глибини у `showAppSheet` спаде як завжди.
class _RouteStack extends NavigatorObserver {
  final _stack = <Route<dynamic>>[];

  /// Усе, що лежить над кореневим маршрутом, знизу вгору.
  List<Route<dynamic>> get aboveFirst => [
        for (final r in _stack)
          if (!r.isFirst) r,
      ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final at = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (at < 0) return;
    if (newRoute == null) {
      _stack.removeAt(at);
    } else {
      _stack[at] = newRoute;
    }
  }
}

class QvasApp extends ConsumerStatefulWidget {
  const QvasApp({super.key});

  @override
  ConsumerState<QvasApp> createState() => _QvasAppState();
}

class _QvasAppState extends ConsumerState<QvasApp>
    with WidgetsBindingObserver {
  final _snapshots = InputSnapshotStore();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _routes = _RouteStack();
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Стартова ініціалізація не блокує перший кадр (бюджет, тех. спека п.6):
    // пад малюється одразу, решта доїжджає наступними кадрами.
    Future(() async {
      // Валюта першого запуску — автовизначення з системної локалі
      // (Функціонал п.5.1). Далі керується з налаштувань.
      ref.read(settingsRepositoryProvider).initialCurrencyCode =
          detectCurrencyCode(PlatformDispatcher.instance.locale);
      await ref.read(startupProvider.future);
      // Відновлення стану вводу після смерті процесу (Функціонал п.11).
      final snapshot = await _snapshots.readFresh();
      if (snapshot != null) {
        ref.read(inputProvider.notifier).restore(snapshot);
      }
      await _snapshots.clear();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pausedAt = DateTime.now();
        final input = ref.read(inputProvider);
        final hasContent =
            input.amount != const InputState().amount ||
                input.categoryId != null;
        if (hasContent) {
          _snapshots.write(input);
        } else {
          _snapshots.clear();
        }
      case AppLifecycleState.resumed:
        // Повернення пізніше ніж за 10 хвилин — стан вводу скидається,
        // а застосунок повертається на Екран 1 (рішення 30): після довгої
        // паузи людина відкриває його, щоб занести суму, а не дивитись
        // на місці, де колись зупинилась.
        //
        // Маршрути саме ВИДАЛЯЮТЬСЯ, а не спливають (рішення 82). `popUntil`
        // програвав зворотний перехід уже на видимому екрані: людина
        // відкривала застосунок і встигала побачити, як Екран 2 з'їжджає
        // вниз. Показувати шлях назад нема кому — його ніхто не проходив,
        // а пауза тривала довше за будь-яку анімацію.
        final pausedAt = _pausedAt;
        if (pausedAt != null &&
            DateTime.now().difference(pausedAt) >
                InputSnapshotStore.maxAge) {
          ref.read(inputProvider.notifier).reset();
          final navigator = _navigatorKey.currentState;
          for (final route in _routes.aboveFirst.reversed) {
            navigator?.removeRoute(route);
          }
          // Тут же перераховуються бульбашки (рішення 84). Рішення 83
          // прив'язало перерахунок до запуску процесу — і цього мало:
          // застосунок такого штибу зазвичай не закривають, а згортають,
          // тож процес живе днями, а склад слотів лишався б із першого
          // відкриття. Довга пауза — це і є межа сесії, яку застосунок
          // уже визнає: саме тут скидається ввід і зникає Екран 2.
          //
          // Кнопки при цьому не рухаються під пальцем: екран у цей
          // момент і так повертається у вихідний стан. Стара п'ятірка
          // лишається видимою, доки рахується нова, — Riverpod тримає
          // попереднє значення при перерахунку, тож підміни на запасний
          // порядок не видно.
          ref.invalidate(smartSlotsProvider);
        }
        _snapshots.clear();
        _pausedAt = null;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Мова — наше налаштування, не системне per-app (тех. спека п.11.3).
    // Фолбек — англійська (Функціонал п.6).
    final localeTag = ref.watch(localeTagProvider);
    return MaterialApp(
      title: 'QVAS',
      navigatorKey: _navigatorKey,
      navigatorObservers: [_routes],
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: Locale(localeTag),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          // Системний масштаб тексту підтримується до 130% (DS п.6).
          // Далі пад і суми ламаються, тому стеля явна. Знизу не
          // обмежуємо: зменшений текст — теж налаштування доступності.
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
      home: const _Root(),
    );
  }
}
