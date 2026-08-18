import 'package:flutter/material.dart';

/// Токени з Design System & UI/UX Guidelines. Єдине джерело правди для
/// кольорів, радіусів, відступів, тривалостей і типографіки.
/// Значення не змінюються локально в екранах — тільки тут.

abstract final class AppColors {
  // Рішення 58 (2026-08-16): нейтралі тоновані в холодне (hue ~230,
  // sat 6-8%) при тій самій світлості. Чисто-сірий читався як «колір
  // не обирали» — це та сама сітка значень, що в темній темі Material
  // за замовчуванням. Контрасти з DS п.1.3 не зсунулись.
  //
  // Рішення 37 лишається чинним: шари розділяються яскравістю
  // поверхонь, а не лініями.

  static const bgBase = Color(0xFF0C0D10);

  /// Той самий RGB, що [bgBase], з нульовою альфою. Потрібен окремою
  /// константою, бо `withValues` не const, а градієнт заголовка дня
  /// у feed.dart перемальовується щокадру скролу. Пару тримає
  /// color_tokens_test.dart — раніше там стояв хардкод, який мовчки
  /// розійшовся б із фоном при першій же зміні палітри.
  static const bgBaseFade = Color(0x000C0D10);

  /// Панель підсумків на Екрані 2 — власний рівень: тьмяніша за шторки,
  /// щоб велика площа не світилась, але читалась як окремий шар.
  static const bgPanel = Color(0xFF16171C);

  /// Натиснута ПІДНЯТА поверхня. Рішення 59: клавіша, яка пішла вниз,
  /// виходить з-під світла, тож натиснуте темнішає, а не світлішає.
  /// Навмисно не дорівнює [bgWell] — інакше натиснута клітинка
  /// зникала б у плиті під падом.
  ///
  /// Пласких рядків на [bgBase] це правило НЕ стосується: там темніти
  /// нічого, і натиснутий стан лишається світлішим ([bgSurface]).
  static const bgPressed = Color(0xFF15171C);

  static const bgSurface = Color(0xFF1C1E24);

  /// Підсвітка натиснутого ПЛАСКОГО рядка — тонкий білий серпанок поверх
  /// того, на чому рядок лежить.
  ///
  /// Це друга половина правила з [bgPressed], і разом вони покривають усі
  /// випадки: у піднятої поверхні є власна заливка, тож натиснута вона
  /// темнішає (виходить з-під світла); у плаского рядка заливки немає —
  /// темніти нічому, тож він світлішає.
  ///
  /// Саме накладка, а не ще один іменований фон: рядки лежать на різних
  /// поверхнях (налаштування — на [bgBase], шторки — на [bgSheet]), і
  /// будь-яке фіксоване значення було б світлішим за одну й темнішим за
  /// іншу. Накладка світлішає рівно на стільки ж, хоч би що було під нею.
  ///
  /// Правило закодоване тим, ЯКИЙ компонент береться: `AppRow` —
  /// накладка, `Pressable` із власною заливкою — [bgPressed]. Прапорця,
  /// який треба щоразу згадувати, тут навмисно немає.
  static const pressOverlay = Color(0x12FFFFFF); // white 7%

  /// Поверхня шторки. Раніше цю роль і роль «натиснутого стану» ніс
  /// один токен `bgSurfaceHigh` — дві різні речі одним значенням, через
  /// що натиснутий стан не міг змінитись без зміни всіх шторок.
  ///
  /// Рішення 80 (2026-08-16): `#292C34` → `#121419`, тобто шторка стала
  /// темним шаром замість світлого. Це не підбір відтінку, а виправлення
  /// моделі.
  ///
  /// Правило «що вище шар, то світліша поверхня» порівнювало різні речі:
  /// [bgSheet] — це ШАР над екраном, а [bgSurface] — заливка КОНТРОЛА.
  /// Поки шторка мусила бути світлішою за все, що на ній лежить, вона
  /// виходила найсвітлішою великою площиною майже чорного застосунку —
  /// і всередині неї модель освітлення перекидалась: поле пошуку,
  /// кнопки й аватарки читались як заглиблення, хоча всюди інде
  /// підняте — світліше.
  ///
  /// Тепер напрямок один на весь застосунок: шторка на крок світліша за
  /// [bgBase] (видно край над затемненим тлом), а контроли на ній —
  /// світліші за неї, рівно як клавіші пада на Екрані 1.
  static const bgSheet = Color(0xFF121419);

  /// Тост — найвищий шар застосунку, тож і найсвітліша поверхня.
  /// Раніше він мав той самий колір, що шторка, і поверх шторки просто
  /// зникав: лишався текст, який висів у повітрі.
  static const bgToast = Color(0xFF35383F);

  static const borderHairline = Color(0x14FFFFFF); // white 8%

  // Дія та бренд.
  //
  // Рішення 68 (2026-08-16): акцент більше не системний зелений iOS.
  // `#34C759` — значення з коробки Apple, і поки воно тут стояло,
  // застосунок кольором нічим не відрізнявся від будь-якого іншого.
  // Відтінок лишився той самий (це не м'ята — рішення 34 її свідомо
  // відкинуло), змінилась насиченість і світлість.
  //
  // Обирати треба ОДИН хекс. Похідні виводяться з нього формулою —
  // див. [_pressed] і [_subtle]; за формулою стежить
  // `test/color_tokens_test.dart`.
  static const accent = Color(0xFF2FDA76);
  static final accentPressed = _pressed(accent);
  static const onAccent = Color(0xFF0B0B0D);
  // accentSubtle прибраний 2026-08-16: єдиним його споживачем була
  // заливка вибраної капсули категорії, а вибір тепер позначає сама
  // обводка. Мертвих токенів у палітрі не тримаємо.

  // Дохід. Рішення 50 (2026-08-15, переглядає рішення 07): зелений —
  // звичний користувачам колір доходу. Той самий відтінок, що акцент:
  // один зелений на весь застосунок, тип запису розрізняє знак «+».
  static const income = accent;
  static final incomeSubtle = _subtle(accent);

  /// Зелений «упівголоса»: символ валюти й нуль на Екрані 1 у режимі
  /// доходу (рішення 78). Не другий відтінок — той самий колір, ослаблений
  /// прозорістю, тобто підмішаний до фону.
  ///
  /// 60% узяті не на око. На [bgBase] це дає контраст ≈4.3:1 проти 3.8:1
  /// у [textTertiary], який тут стояв доти: колір міняється, вага в
  /// композиції — ні. Саме цього ми й хочемо, бо приглушеність тут
  /// означає «це не головне число», а не «це вимкнено».
  static final incomeMuted = income.withValues(alpha: 0.60);

  // Видалення — червоний означає ТІЛЬКИ видалення
  static const danger = Color(0xFFFF3B30);
  static final dangerSubtle = _subtle(danger);
  static const textOnDanger = Color(0xFFFFFFFF);

  /// Від'ємна «Різниця» (рішення 69). Головна цифра застосунку не мала
  /// кольору саме в найважливішому випадку — витратив більше, ніж
  /// заробив.
  ///
  /// ⚠️ **Правило «червоний означає ТІЛЬКИ видалення» тут свідомо
  /// призупинене** (2026-08-16, на пробу). Спершу стояв бурштин
  /// `#FFB020` — окремий відтінок, який ні з чим не плутався. Зараз
  /// узятий приглушений червоний, і за відтінком він практично
  /// збігається з [danger] (обидва ≈0–4°). Отже одна колірна родина
  /// водночас позначає плашку свайпу-видалення, кнопку «Замінити» при
  /// імпорті — і підсумок місяця.
  ///
  /// Це проба, а не нова норма. Якщо лишається — правило в DS треба
  /// переписати явно, бо інакше воно існує лише на папері.
  ///
  /// Межу все одно стерегти: колір не має протікти ні в суми рядків
  /// стрічки, ні в підсумок фільтра — інакше «Різниця» перестане бути
  /// особливою.
  static const warn = Color(0xFFC43D3D);

  /// Натиснутий варіант акценту: та сама світлість, помножена на 0.885.
  /// Коефіцієнт не вигаданий — його вже містила пара `#34C759` /
  /// `#2DB14E`, підібрана рукою. Ми не винаходимо деривацію, а
  /// записуємо ту, що й так була.
  static Color _pressed(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.885).clamp(0.0, 1.0))
        .toColor();
  }

  /// Ледь помітна заливка того ж кольору — 12%, як і було.
  static Color _subtle(Color c) => c.withValues(alpha: 0.12);

  // Текст
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF98989D);
  static const textTertiary = Color(0xFF6E6E73);
}

abstract final class AppRadius {
  /// Панель підсумків та великі картки (рішення 37, [[Monobank]] п.4).
  static const card = 24.0;
  static const button = 16.0;
  static const sheet = 28.0;
  static const pill = 999.0;

  /// Радіус прямокутної поверхні виводиться з її висоти, а не обирається.
  ///
  /// Правило, яке в застосунку вже діяло, але ніде не було записане:
  /// елемент керування (клавіша пада 64, «Зберегти» 56, тост ~52) має
  /// [button], велика площина (панель підсумків) — [card]. Поріг стоїть
  /// вище за найбільший елемент керування й нижче за найменшу площину,
  /// тож жодне з наявних значень не зсувається.
  ///
  /// **Капсула правилом не виводиться, а оголошується.** Бульбашка
  /// категорії (44) і перемикач типу (36) — це [pill] не тому, що вони
  /// такої висоти, а тому, що вони капсули: форма несе сенс «це вибір»,
  /// і з висотою вона не пов'язана. Так само [sheet] — власна роль, а не
  /// «дуже висока поверхня».
  ///
  /// Хелпер введений заради того, щоб правило існувало в коді, а не в
  /// пам'яті: аудит порушниць серед прямокутників не знайшов.
  static double forHeight(double height) =>
      height >= _cardThreshold ? card : button;

  static const _cardThreshold = 80.0;
}

abstract final class AppSpace {
  /// Бічні поля екрана.
  static const side = 20.0;

  /// Вертикальний ритм між блоками.
  static const block = 24.0;

  /// Проміжки бульбашок категорій (горизонталь і вертикаль).
  static const bubbleGap = 8.0;

  /// Проміжок між клітинками пада.
  static const padGap = 8.0;
}

abstract final class AppSize {
  /// Мінімальна ціль дотику (вимога Android).
  static const minTouch = 48.0;

  /// Три щільності рядка списку — і більше жодної. До зведення в `AppRow`
  /// ці самі числа стояли розсипом у семи файлах.
  ///
  /// [rowCompact] — рядок-вибір, де вміст один рядок тексту (мова,
  /// валюта); [row] — типовий рядок з емодзі й діями; [rowTall] — рядок
  /// із другим рівнем, тобто з коментарем під назвою.
  static const rowCompact = 52.0;
  static const row = 56.0;
  static const rowTall = 68.0;

  /// Кружечок емодзі в рядку.
  static const avatar = 40.0;

  /// Клітинка цифрового пада; на екранах <680dp — small.
  static const padCell = 64.0;
  static const padCellSmall = 56.0;

  /// Капсула категорії. Зменшено 2026-08-14: пріоритет вертикалі — цифрам
  /// і паду, бульбашки стають у два ряди (рішення 32).
  static const bubble = 44.0;
  static const bubbleSmall = 40.0;

  /// Кнопка «Зберегти».
  static const saveButton = 56.0;

  /// Капсула перемикача «Витрата / Дохід».
  static const typeSwitch = 36.0;

  /// Поріг «малого екрана» по висоті.
  static const smallScreenHeight = 680.0;

  /// Зарезервована висота під рядок виразу калькулятора.
  /// Зарезервоване місце під рядок виразу калькулятора. 24 → 28
  /// (2026-08-16): при системному масштабі тексту 130% рядковий бокс
  /// Inter на 16pt виходить ~25dp і давав смужку переповнення. Уся
  /// робота цього рядка — щоб нічого не стрибало, тож він має вміщати
  /// текст на будь-якому дозволеному масштабі.
  static const expressionRow = 28.0;
}

abstract final class AppDurations {
  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 320);

  /// Поява нового запису в стрічці (рішення 56): рядок розгортається
  /// по висоті + scale + прозорість — ефект зникнення навпаки.
  static const appear = Duration(milliseconds: 300);

  /// Добігання цифри до нового значення (метрики Екрана 2). Окремий
  /// токен, а не `standard`: тут рахується не поява елемента, а зміна
  /// величини, і 250 мс — це стеля, за якої око ще встигає прочитати
  /// проміжні значення як рух, а не як миготіння.
  static const count = Duration(milliseconds: 250);

  /// Перехід на повноекранний маршрут (Налаштування, Інструкція,
  /// Категорії; рішення 76). Явний токен, бо інакше його ніхто не задає:
  /// [MaterialPageRoute] бере тривалість не з себе, а з білдера теми, а
  /// [PredictiveBackPageTransitionsBuilder] віддає 450 мс — це
  /// апроксимація пружин Material 3 Expressive, яких у Flutter поки
  /// немає. На пристрої це виходив найповільніший рух у застосунку,
  /// довший навіть за наїзд Історії ([sheet], 320 мс), хоча Історія
  /// рухає весь екран, а тут лише проявлення зі зсувом. 260 мс лишає
  /// той самий перехід, але вкладає його у шкалу решти анімацій.
  static const page = Duration(milliseconds: 260);

  /// «Прибрати анімації» в системі → всі тривалості стають 0 (DS п.6).
  /// Хаптика при цьому лишається.
  static Duration of(BuildContext context, Duration base) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : base;
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  // easeOutBack прибрано: рішення 56 явно відмовилось від overshoot,
  // і в застосунку немає жодного руху, який мав би «перестрибувати».
}

abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  /// Сума на цифровому паді (на низьких екранах — 48).
  static const display = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
    height: 1.1,
  );

  /// Рядок виразу калькулятора під сумою.
  static const expression = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  /// «Різниця» на Екрані 2. Збільшено 40 → 48 (рішення 51, 2026-08-15).
  static const metric = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// «Витрати» / «Доходи» на Екрані 2. Збільшено 24 → 28 (рішення 51).
  static const metricSub = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Заголовки шторок.
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Назва категорії в стрічці, сума в рядку, підписи кнопок.
  static const bodyStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Коментар, підписи.
  static const caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Цифра на клітинці пада.
  static const padDigit = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Емодзі-іконка: вшитий сабсет Noto, а не набір вендора (рішення 08).
  ///
  /// **Сімейство задається явно, і покластись на `fontFamilyFallback`
  /// у [buildAppTheme] тут не вийшло.** Перевірено на пристрої: тема
  /// свій fallback несе (`Inter / [NotoColorEmoji]`, і `merge` його
  /// зберігає), шрифт у APK лежить і в `FontManifest.json` зареєстрований
  /// — але картинка з ним і без нього збігалась піксель у піксель, тобто
  /// рушій продовжував брати системні емодзі. Щойно сімейство стало
  /// основним для стилю, зображення змінилось. Тож єдиний спосіб, який
  /// справді працює, — назвати сімейство прямо в стилі тексту.
  ///
  /// Розмір параметром, бо він різний у трьох місцях: `18` у капсулах
  /// Екрана 1, `20` у кружечку рядка, `28` у сітці пікера.
  static TextStyle emoji(double size) =>
      TextStyle(fontFamily: 'NotoColorEmoji', fontSize: size);
}

/// Штатний перехід Android, але тривалістю [AppDurations.page].
///
/// Сам рух і предиктивний back лишаються батьківськими — змінюється
/// тільки годинник. Скоротити його з боку маршруту не вийшло б:
/// `MaterialRouteTransitionMixin.transitionDuration` читає саме білдер
/// теми, а `transitionDuration` у [MaterialPageRoute] — гетер без
/// параметра. Зворотний бік окремо не задаємо: базовий
/// `reverseTransitionDuration` дорівнює прямому.
class _AppPageTransitionsBuilder extends PredictiveBackPageTransitionsBuilder {
  const _AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppDurations.page;
}

/// Глобальна тема. Темна завжди — світлої теми не існує (рішення DS п.1.2).
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.bgBase,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bgBase,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.income,
      error: AppColors.danger,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    // Перехід «углиб» — один на всі маршрути, і саме той, який Android
    // дає за замовчуванням.
    //
    // Спокуса була переписати маршрути на `PageRouteBuilder` заради
    // однаковості з [historyRoute]. Так робити НЕ можна:
    // [PredictiveBackPageTransitionsBuilder] вмикає предиктивний back
    // Android 15 (жест назад показує екран під поточним), і вмикає його
    // саме [MaterialPageRoute] через тему. Сирий `PageRouteBuilder`
    // мовчки забрав би цю поведінку — реальна регресія заради косметики.
    //
    // Тут вона просто закріплена явно: тепер видно, що перехід обраний,
    // а не дістався з коробки. Скорочений він теж тут — інакше ніде:
    // див. [_AppPageTransitionsBuilder].
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: _AppPageTransitionsBuilder()},
    ),
  );
}
