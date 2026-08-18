import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/input_providers.dart';
import '../common/type_capsule.dart';

/// Перемикач «Витрата / Дохід» на Екрані 1 — [TypeCapsule], прив'язана
/// до стану вводу. Уся картинка й правила відгуку живуть у капсулі.
class TypeSwitch extends ConsumerWidget {
  const TypeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TypeCapsule(
      type: ref.watch(inputProvider.select((s) => s.type)),
      onTap: () => ref.read(inputProvider.notifier).toggleType(),
    );
  }
}
