import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qvas/ui/settings/settings_screen.dart';

/// Версія в «Про застосунок» живе константою в коді, бо package_info
/// тягнув би плагін заради одного рядка. Ціна такого рішення — вона
/// мовчки розходиться з pubspec (на аудиті 2026-08-15 розійшлась на дві
/// мінорні версії). Цей тест робить розходження гучним.
void main() {
  test('appVersion збігається з версією в pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*(\S+?)\+', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'version: у pubspec.yaml не знайдено');
    expect(
      appVersion,
      match!.group(1),
      reason: 'Підніми appVersion у settings_screen.dart разом із pubspec',
    );
  });
}
