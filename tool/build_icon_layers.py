#!/usr/bin/env python3
"""Збирає шари іконки застосунку з assets/icon/source.png.

Робить усе за раз:
  1. вирізає світлий знак на прозорий передній шар
  2. добудовує тло тим самим діагональним градієнтом
  3. кладе копію переднього шару як монохромну іконку (Android 13)
  4. ріже іконку 512×512 для сторінки Play

Запускати після будь-якої зміни source.png, далі — `dart run
flutter_launcher_icons`, який розкладе результат по mipmap і drawable.

Джерело — квадрат 1024×1024, світлий знак на темному тлі: передній шар
вирізається за яскравістю. Якщо знак буде темним або тло світлим, різати
доведеться інакше.

Два перетворення тут не косметичні.

**Безпечне коло.** Маски лаунчерів різні, і єдина форма, яку не ріже жодна
з них, — коло діаметром 66 зі 108dp. Скрипт міряє, як далеко від центру
відходить найдальший піксель знака, і зменшує знак рівно тоді, коли той
за коло виходить. Композицію джерела при цьому не чіпає: якщо знак
уміщається, він лишається того самого розміру, що й намальований.

**Інсет.** flutter_launcher_icons обгортає передній шар у <inset 16%>,
тобто малює його на 68% полотна. Тому у файл шар пишеться більшим рівно
настільки, щоб після інсету знак став на місце.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parent.parent
ICON = ROOT / "assets" / "icon"
S = 1024
INSET = 0.16                      # інсет, який додає flutter_launcher_icons
DRAWN = 1 - 2 * INSET             # частка полотна, на якій шар реально малюється
SAFE_R = S * 66 / 108 / 2         # радіус безпечного кола в готовій іконці

src = Image.open(ICON / "source.png").convert("RGB")
if src.size != (S, S):
    src = src.resize((S, S), Image.LANCZOS)
a = np.asarray(src).astype(np.float32)

# --- передній шар: світлий знак на прозорому --------------------------------
# Тло в джерелі темніше за 50, знак — чисто білий, тож поріг 80 відрізає тло
# повністю й лишає згладжені краї.
alpha = np.clip((a.max(axis=2) - 80.0) / (255.0 - 80.0), 0, 1)
mark = np.zeros((S, S, 4), np.uint8)
mark[..., :3] = 255
mark[..., 3] = (alpha * 255).round().astype(np.uint8)

ys, xs = np.nonzero(alpha > 0.5)
reach = float(np.hypot(xs - S / 2, ys - S / 2).max())
fit = min(1.0, SAFE_R / reach)    # зменшуємо тільки якщо знак виходить за коло
scale = fit / DRAWN               # плюс компенсація інсету

layer = Image.fromarray(mark, "RGBA")
side = round(S * scale)
layer = layer.resize((side, side), Image.LANCZOS)
canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
canvas.paste(layer, ((S - side) // 2, (S - side) // 2), layer)
canvas.save(ICON / "adaptive_foreground.png")
canvas.save(ICON / "adaptive_monochrome.png")
print(f"знак відходить від центру на {reach:.0f} з дозволених {SAFE_R:.0f} -> "
      f"{'вписуємо, ×' + format(fit, '.3f') if fit < 1 else 'лишаємо як є'}")

# --- тло: той самий градієнт, продовжений за межі видимої зони --------------
# Маска показує лише центральні 72 зі 108dp, тому градієнт розтягується
# назовні: у точках 1/6 і 5/6 полотна він має дати кольори кутів джерела.
tl, br = a[8, 8], a[S - 8, S - 8]
hi = tl + (tl - br) * 0.25
lo = br + (br - tl) * 0.25
ramp = np.linspace(0, 1, S)
t = (ramp[None, :] + ramp[:, None]) / 2.0
bg = hi + (lo - hi) * t[..., None]
Image.fromarray(np.clip(bg, 0, 255).astype(np.uint8), "RGB").save(
    ICON / "adaptive_background.png")
print(f"градієнт {hi.round().astype(int)} -> {lo.round().astype(int)}")

# --- іконка сторінки Play ---------------------------------------------------
src.resize((512, 512), Image.LANCZOS).save(ICON / "play_store_512.png")
