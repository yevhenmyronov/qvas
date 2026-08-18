import 'package:drift/drift.dart';

import '../models/tx_type.dart';

/// Схема — тех. спека п.2.1. Enum-и зберігаються текстом ('expense'/'income'),
/// щоб дамп бази й JSON-експорт читались очима і не ламались від зміни
/// порядку значень enum.

class Categories extends Table {
  /// uuid; для вбудованих — детермінований v5 від nameKey, щоб імпорт
  /// у режимі «додати» не плодив дублікати між установками.
  TextColumn get id => text()();

  TextColumn get type => textEnum<TxType>()();

  /// 'cat.coffee' — для вбудованих, перекладається на льоту.
  TextColumn get nameKey => text().nullable()();

  /// Для створених користувачем; не перекладається ніколи.
  TextColumn get customName => text().nullable()();

  TextColumn get emoji => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  /// Закріплена вручну, максимум 5.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// Замість видалення — щоб не ламати історію.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<TxType>()();

  /// Мінорні одиниці: 8500 == 85 ₴. Завжди кратне 100 (пад без крапки).
  IntColumn get amountMinor => integer()();

  TextColumn get categoryId => text().references(Categories, #id)();

  /// Завжди дорівнює валюті з налаштувань (рішення 57): зміна валюти
  /// переписує колонку в усіх записах. Колонка лишається, щоб експорт
  /// і CSV були самоописовими.
  TextColumn get currencyCode => text()();

  /// Точний момент у UTC. Використовується виключно для сортування
  /// всередині дня — користувачу не показується ніде (рішення 29).
  DateTimeColumn get createdAtUtc => dateTime()();

  /// 'yyyy-MM-dd' з локального часу в момент запису (тех. спека п.2.3).
  TextColumn get localDateKey => text()();

  /// До 60 символів.
  TextColumn get note => text().nullable()();

  /// М'яке видалення заради Undo; фізичне очищення — фоном через 30 днів.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Один рядок (id завжди 1).
class AppSettings extends Table {
  IntColumn get id => integer()();

  /// Валюта всього застосунку (рішення 57) — і показу, і всіх записів.
  TextColumn get currencyCode => text()();

  /// null = брати системну.
  TextColumn get localeOverride => text().nullable()();

  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();

  /// Ставиться один раз при першому запуску; від неї рахуються
  /// 72 години тріалу (тех. спека п.13).
  DateTimeColumn get firstLaunchAt => dateTime()();

  /// Коли востаннє робили JSON-бекап — для банера-нагадування
  /// (Функціонал п.7.3). null — жодного разу.
  DateTimeColumn get lastBackupAt => dateTime().nullable()();

  /// Банер нагадування закривається назавжди одним тапом.
  BoolColumn get backupBannerDismissed =>
      boolean().withDefault(const Constant(false))();

  /// Перемикач «Хаптика» — вимикає обидва місця вібрації (п.2.6).
  BoolColumn get hapticsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Бітова маска показаних підказок (рішення 89).
  ///
  /// Одна колонка на всі підказки, а не колонка на кожну: їх максимум
  /// три за все життя застосунку, і кожна нова інакше означала б ще
  /// одну міграцію схеми на встановленій базі.
  IntColumn get hintsShown => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Кеш ранжування Smart Categories (тех. спека п.4): готовий склад слотів,
/// щоб при старті не виконувати агрегацію. Перераховується раз на добу.
class CategoryRankingCache extends Table {
  TextColumn get type => textEnum<TxType>()();

  /// Позиція слота 0..4.
  IntColumn get position => integer()();

  TextColumn get categoryId => text()();

  /// Ранг на момент обчислення — потрібен гістерезису при перерахунку.
  IntColumn get rank => integer()();

  /// localDateKey дня, для якого обчислено.
  TextColumn get computedOn => text()();

  @override
  Set<Column> get primaryKey => {type, position};
}
