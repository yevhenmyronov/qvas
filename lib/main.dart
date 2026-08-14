import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/currency.dart';
import 'providers/core_providers.dart';
import 'providers/input_providers.dart';
import 'services/input_snapshot_store.dart';
import 'theme/tokens.dart';
import 'ui/input/input_screen.dart';

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

class QvasApp extends ConsumerStatefulWidget {
  const QvasApp({super.key});

  @override
  ConsumerState<QvasApp> createState() => _QvasAppState();
}

class _QvasAppState extends ConsumerState<QvasApp>
    with WidgetsBindingObserver {
  final _snapshots = InputSnapshotStore();
  final _navigatorKey = GlobalKey<NavigatorState>();
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
        final pausedAt = _pausedAt;
        if (pausedAt != null &&
            DateTime.now().difference(pausedAt) >
                InputSnapshotStore.maxAge) {
          ref.read(inputProvider.notifier).reset();
          _navigatorKey.currentState?.popUntil((r) => r.isFirst);
        }
        _snapshots.clear();
        _pausedAt = null;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QVAS',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // v0.1: мова захардкожена (uk). Без цього системні віджети —
      // календар, семантика — говорять англійською.
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const InputScreen(),
    );
  }
}
