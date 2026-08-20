#!/usr/bin/env python3
"""Ріже Inter до того, що застосунок реально малює (рішення 90).

Повний Inter несе 2852 гліфи на кожну з п'яти насиченостей — грецьку,
фонетичний алфавіт, псевдографіку, стрілки. Застосунок із них показує
латиницю, кирилицю, цифри, пунктуацію й валютні знаки.

Вихідні шрифти в репозиторії не лежать (рішення 96 переглядає 90):
завантаж статичні TTF з https://github.com/rsms/inter/releases і поклади
в `tool/inter-src/` п'ять файлів — Regular, Medium, SemiBold, Bold,
ExtraBold. Разом вони важать ~2 МБ; поки репозиторій був локальним,
тримати їх поруч було дешевше за завантаження, а в публічному вони
стали двома мегабайтами, які качає кожен, хто клонує.

Запуск:  python tool/build_inter_subset.py
"""

import re
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "tool" / "inter-src"
OUTPUT_DIR = ROOT / "assets" / "fonts"

WEIGHTS = [
    "Inter-Regular",
    "Inter-Medium",
    "Inter-SemiBold",
    "Inter-Bold",
    "Inter-ExtraBold",
]

# Що лишається. Діапазонами, а не переліком використаних символів:
# частину тексту застосунок бере не зі своїх рядків, а з `intl` —
# назви місяців, розділювачі розрядів, валютні знаки з вшитої таблиці.
# Перелічити це сканом неможливо, тож межа проводиться по блоках.
KEEP_RANGES = [
    (0x0000, 0x024F),  # латиниця з розширеннями A і B
    # Модифікатори — заради U+02BC, українського апострофа. Саме він
    # стоїть у «Зв'язок» і «пам'ять»; без нього ці слова втрачають гліф.
    # Знайдено перевіркою нижче, а не оком.
    (0x02B0, 0x02FF),
    (0x0300, 0x036F),  # комбіновані діакритики
    (0x0400, 0x04FF),  # кирилиця
    (0x2000, 0x206F),  # пунктуація: тире, лапки, нерозривні пробіли
    (0x20A0, 0x20BF),  # валютні знаки: ₴ € ₽ ₺ ₹ …
    (0x2100, 0x214F),  # № і подібні
]

# Поодинокі символи поза блоками вище, які трапляються в коді.
KEEP_SINGLES = [
    0x2192,  # →
    0x2212,  # − (мінус, не дефіс)
    0x2248,  # ≈
    0x2715,  # ✕
    0x232B,  # ⌫ — у тексті інструкції; на паді це Material-іконка,
    #             але в довідці стоїть саме символ
    0xFF0B,  # ＋
    0xFFFD,  # � — щоб невідомий символ не ставав порожнечею
]

STRING_LITERAL = re.compile(r"'([^']*)'")


def keep_codepoints() -> set[int]:
    keep = {cp for lo, hi in KEEP_RANGES for cp in range(lo, hi + 1)}
    keep.update(KEEP_SINGLES)
    return keep


def emoji_codepoints() -> set[int]:
    """Те, що малює вшитий Noto, а не Inter (тех. спека п.7).

    Береться з `emoji-set.txt`, а не з діапазонів: половина наших
    емодзі — це BMP-символи (`☕`, `⛽`, `➕`), які за номером не
    відрізниш від типографіки.
    """
    path = ROOT / "emoji-set.txt"
    if not path.exists():
        return set()
    return {
        int(m.group(1), 16)
        for m in (re.match(r"^([0-9A-F]{4,6})\b", line)
                  for line in path.read_text(encoding="utf-8").splitlines())
        if m
    }


def used_in_sources() -> set[int]:
    """Усе, що є в рядках коду й у перекладах — для перевірки, не для різання."""
    used: set[int] = set()
    for path in [*(ROOT / "lib").rglob("*.dart"),
                 *(ROOT / "lib" / "l10n" / "arb").glob("*.arb")]:
        text = path.read_text(encoding="utf-8")
        chunks = STRING_LITERAL.findall(text) if path.suffix == ".dart" else [text]
        for chunk in chunks:
            used.update(ord(c) for c in chunk if ord(c) >= 0x20)
    return {cp for cp in used if cp < 0x1F000} - emoji_codepoints()


def build() -> None:
    if not SOURCE_DIR.exists():
        sys.exit(f"Немає вихідних шрифтів: {SOURCE_DIR}")

    keep = keep_codepoints()

    # Перевірка ДО різання: чи не викидаємо ми щось, що реально
    # трапляється в коді або перекладах.
    missing = sorted(cp for cp in used_in_sources() if cp not in keep)
    if missing:
        listed = ", ".join(f"U+{cp:04X} {chr(cp)!r}" for cp in missing)
        sys.exit(f"Ці символи є в коді, але випадають із сабсету: {listed}")

    total_before = total_after = 0
    for name in WEIGHTS:
        source = SOURCE_DIR / f"{name}.ttf"
        if not source.exists():
            sys.exit(f"Немає {source}")

        font = TTFont(source)
        available = keep & set(font.getBestCmap())

        options = subset.Options()
        options.set(layout_features=["*"], notdef_outline=True)
        subsetter = subset.Subsetter(options=options)
        subsetter.populate(unicodes=available)
        subsetter.subset(font)

        target = OUTPUT_DIR / f"{name}.ttf"
        font.save(target)

        total_before += source.stat().st_size
        total_after += target.stat().st_size
        print(f"{name}: {source.stat().st_size / 1024:.1f} → "
              f"{target.stat().st_size / 1024:.1f} KB")

    print(f"\nразом: {total_before / 1024:.1f} → {total_after / 1024:.1f} KB "
          f"(−{(total_before - total_after) / 1024 / 1024:.2f} МБ)")


if __name__ == "__main__":
    build()
