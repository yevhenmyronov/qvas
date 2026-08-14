import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/core_providers.dart';
import 'theme/tokens.dart';

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

class QvasApp extends ConsumerWidget {
  const QvasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Стартова ініціалізація йде паралельно — перший кадр її не чекає.
    ref.watch(startupProvider);
    return MaterialApp(
      title: 'QVAS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(body: SizedBox.expand()),
    );
  }
}
