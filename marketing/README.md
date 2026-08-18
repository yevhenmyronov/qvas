# Матеріали для презентації

Знімки екранів для сторінки Play і презентацій. Зняті з **демо-застосунку**
`com.qvas.app.demo` — окремої збірки з власною базою. Робоча база догфудингу
(`com.qvas.app`) при цьому не відкривається взагалі.

## Що знято

| Файл | Що показує |
|---|---|
| `01-input-empty.png` | Екран 1 у спокої: пад відкритий одразу, п'ять закріплених категорій |
| `02-input-ready.png` | Сума й категорія зійшлись — «Зберегти» залите зеленим |
| `03-history.png` | Екран 2: «Різниця», підсумки місяця, стрічка з нотатками |
| `04-breakdown.png` | Розбивка витрат за категоріями (шторка з панелі підсумків) |
| `05-filter-category.png` | Фільтр за категорією: тільки «Кафе» і сума по ній |
| `06-quick-edit.png` | Шторка редагування запису: сума, категорія, нотатка, дата |
| `07-categories.png` | Повний список категорій, закріплення й пошук |
| `08-income.png` | Режим доходу: зелені цифри, власний набір категорій |
| `09-settings.png` | Налаштування: валюта, мова, резервна копія, CSV |
| `10-calculator.png` | Калькулятор просто на паді: `800 + 400` під сумою |
| `contact-sheet.png` | Усі знімки в один ряд, для швидкого перегляду |

## Як перезняти

Демо-дані описані в [`tool/seed_demo.py`](../tool/seed_demo.py) — суми, нотатки й
дати задані списком, не випадкові. Дати рахуються від константи `TODAY`, тож
для свіжого набору достатньо змінити її.

```bash
flutter build apk --debug --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell monkey -p com.qvas.app.demo -c android.intent.category.LAUNCHER 1
adb exec-out run-as com.qvas.app.demo cat app_flutter/qvas.sqlite > qvas.sqlite
python tool/seed_demo.py qvas.sqlite
adb shell am force-stop com.qvas.app.demo
adb push qvas.sqlite /data/local/tmp/
adb shell "run-as com.qvas.app.demo sh -c 'rm -f app_flutter/qvas.sqlite-wal app_flutter/qvas.sqlite-shm; cp /data/local/tmp/qvas.sqlite app_flutter/qvas.sqlite'"
```

Далі — знімки: `adb exec-out screencap -p > файл.png`.

**Чому саме debug-збірка.** `run-as` працює лише з debuggable-застосунком —
це єдиний спосіб покласти готову базу без рута. Заразом `android/app/build.gradle.kts`
дає debug-збіркам суфікс `.demo`, тож демо ніколи не переписує робочий застосунок.

## Що варто знати перед відправкою в Play

- **Годинник у статусбарі — справжній час зйомки.** HyperOS ігнорує
  `sysui_demo`, тому підмінити його на рівне 9:41 не вийшло. Якщо для сторінки
  потрібен однаковий час на всіх знімках — статусбар доведеться замінити в
  редакторі або обрізати.
- Знімки зроблені на POCO 2511FPC34G, 1268×2756. Play приймає такі як є;
  для feature graphic (1024×500) матеріалу тут немає.
- Мова знімків — українська. Для англомовної сторінки набір треба перезняти,
  перемкнувши мову в налаштуваннях застосунку.
