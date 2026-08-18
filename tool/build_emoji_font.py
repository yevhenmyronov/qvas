#!/usr/bin/env python3
"""Перезбирає сабсет Noto Color Emoji (тех. спека п.7).

Робить усе за раз, бо порізно ці кроки забувають:
  1. знаходить емодзі в lib/
  2. пише emoji-set.txt
  3. ріже вихідний шрифт по цьому списку в assets/fonts/
  4. перевіряє, що результат кольоровий і покриває весь список

Запускати після будь-якої зміни емодзі — у вбудованих категоріях,
у пікері або просто літералом у віджеті. Інакше на місці нового гліфа
буде порожній квадрат; `test/emoji_set_test.dart` ловить це до пристрою.

Вихідний шрифт треба покласти поруч (у репозиторії його немає — 2.9 МБ
проти 264 КБ результату):

    curl -Lo tool/Noto-COLRv1-noflags.ttf \\
      https://raw.githubusercontent.com/googlefonts/noto-emoji/main/fonts/Noto-COLRv1-noflags.ttf

Чому COLRv1, а не бітмапний NotoColorEmoji.ttf з рецепта в спеці:
вектор дає 264 КБ проти кількох мегабайт, бо в бітмапному варіанті вся
вага сидить у таблиці CBDT, і `--no-subset-tables+=CBDT,CBLC` із того
рецепта саме її й лишав недоторканою. Варіант `-noflags` — свідомо:
прапорів країн у наборі немає жодного, а вони половина ваги джерела.
"""

import re
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"
EMOJI_SET = ROOT / "emoji-set.txt"
SOURCE_FONT = ROOT / "tool" / "Noto-COLRv1-noflags.ttf"
OUTPUT_FONT = ROOT / "assets" / "fonts" / "NotoColorEmoji-subset.ttf"

STRING_LITERAL = re.compile(r"'([^']*)'")

# Нижня межа кандидата. Усе під нею — латиниця, кирилиця, пунктуація,
# валютні знаки: там емодзі не буває.
CANDIDATE_FLOOR = 0x2100


def scan_lib() -> set[int]:
    """Кандидати з усього під lib/ — і коду, і перекладів.

    Перша версія брала тільки `db/database.dart` і `l10n/emoji_set.dart`
    і одразу проґавила `'🙂'` — плейсхолдер кнопки вибору, вшитий
    літералом у `ui/sheets/new_category_sheet.dart`.

    Друга брала всі `.dart` — і проґавила ARB: текст інструкції
    (рішення 91) містить `📌`, і врятувало тільки те, що той самий гліф
    уже стояв у коді. Джерело — це будь-який файл, звідки текст
    потрапляє на екран, а не лише той, що закінчується на `.dart`.
    """
    files = sorted([*LIB.rglob("*.dart"), *LIB.rglob("*.arb")])
    if not files:
        sys.exit(f"Немає жодного джерела під {LIB}")

    candidates: set[int] = set()
    for source in files:
        text = source.read_text(encoding="utf-8")
        # В ARB рядки — це значення ключів, тобто майже весь файл;
        # у Dart — тільки літерали.
        chunks = [text] if source.suffix == ".arb" \
            else STRING_LITERAL.findall(text)
        for chunk in chunks:
            candidates |= {ord(c) for c in chunk if ord(c) >= CANDIDATE_FLOOR}
    return candidates


def split_by_font(candidates: set[int], font: TTFont) -> tuple[list[int], list[int]]:
    """Ділить кандидатів на емодзі й типографіку — за самим шрифтом.

    Межа між `➕` (U+2795, емодзі) і `✕` (U+2715, типографічний знак)
    не проходить по діапазонах Unicode: обидва в блоці Dingbats.
    Тому «емодзі» тут визначається операційно — це те, що є в cmap
    Noto. Решта (`→`, `−`, `≈`, `✕`, `＋`) малюється Inter і до
    сабсету стосунку не має.
    """
    cmap = set(font.getBestCmap())
    emoji = sorted(cp for cp in candidates if cp in cmap)
    typographic = sorted(cp for cp in candidates if cp not in cmap)
    return emoji, typographic


def write_set(codepoints: list[int]) -> None:
    lines = [
        "# Згенеровано tool/build_emoji_font.py — руками не правити.",
        "# Джерело: емодзі-літерали в lib/**/*.dart, звірені з cmap Noto.",
        f"# Гліфів: {len(codepoints)}",
        "",
    ]
    lines += [f"{cp:04X}  # {chr(cp)}" for cp in codepoints]
    EMOJI_SET.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build() -> None:
    if not SOURCE_FONT.exists():
        sys.exit(
            f"Немає вихідного шрифту: {SOURCE_FONT}\n"
            "Як його взяти — у docstring цього файлу."
        )

    font = TTFont(SOURCE_FONT)
    emoji, typographic = split_by_font(scan_lib(), font)
    if not emoji:
        sys.exit("Не знайдено жодного емодзі — розійшовся формат джерел?")

    write_set(emoji)

    # Кодові точки йдуть в API напряму, а не через `--unicodes-file`:
    # pyftsubset читає той файл у системному кодуванні, і на українській
    # Windows (cp1251) спотикається об емодзі у коментарях списку.
    options = subset.Options()
    options.set(layout_features=["*"], notdef_outline=True)
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=emoji)
    subsetter.subset(font)
    font.save(OUTPUT_FONT)

    verify(emoji)
    if typographic:
        listed = " ".join(f"U+{cp:04X} {chr(cp)}" for cp in typographic)
        print(f"поза сабсетом (малює Inter): {listed}")


def verify(codepoints: list[int]) -> None:
    font = TTFont(OUTPUT_FONT)
    if "COLR" not in font or font["COLR"].version != 1:
        sys.exit("У результаті немає COLRv1 — колір загубився при різанні.")

    cmap = set(font.getBestCmap())
    missing = [cp for cp in codepoints if cp not in cmap]
    if missing:
        listed = ", ".join(f"U+{cp:04X} {chr(cp)}" for cp in missing)
        sys.exit(f"Гліфи загубились при різанні: {listed}")

    print(
        f"{OUTPUT_FONT.relative_to(ROOT)}: {len(codepoints)} гліфів, "
        f"{OUTPUT_FONT.stat().st_size / 1024:.1f} KB "
        f"(джерело {SOURCE_FONT.stat().st_size / 1024:.1f} KB)"
    )


if __name__ == "__main__":
    build()
