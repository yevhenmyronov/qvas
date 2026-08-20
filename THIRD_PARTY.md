# Third-party notices

QVAS itself is MIT-licensed (see [LICENSE](LICENSE)). It bundles or depends on
the following third-party work.

## Fonts (shipped in this repository)

| Font | License | Source |
|---|---|---|
| Inter | SIL Open Font License 1.1 — [assets/fonts/Inter-OFL.txt](assets/fonts/Inter-OFL.txt) | [rsms/inter](https://github.com/rsms/inter) |
| Noto Color Emoji | SIL Open Font License 1.1 — [assets/fonts/NotoColorEmoji-OFL.txt](assets/fonts/NotoColorEmoji-OFL.txt) | [google/fonts](https://github.com/google/fonts/tree/main/ofl/notocoloremoji) |

Both fonts are shipped **modified**: they are subsets containing only the glyphs
the app actually draws, which is why `assets/fonts/Inter-Regular.ttf` is ~248 KB
instead of the full family, and the emoji font ~264 KB instead of 2.9 MB. The
subsetting scripts are [`tool/build_inter_subset.py`](tool/build_inter_subset.py)
and [`tool/build_emoji_font.py`](tool/build_emoji_font.py).

Neither upstream declares a Reserved Font Name, so the subsets keep the original
family names. The OFL requires that the license text travel with the font files;
that is what the two `.txt` files above are for. Note that the OFL also forbids
selling the fonts on their own — bundling them inside an application, as here, is
explicitly allowed.

## Dart and Flutter packages

Resolved versions live in [`pubspec.lock`](pubspec.lock); the direct dependencies
are:

| Package | License |
|---|---|
| flutter_riverpod | MIT |
| drift, drift_flutter | MIT |
| uuid | MIT |
| file_picker | MIT |
| path_provider | BSD-3-Clause |
| intl | BSD-3-Clause |
| share_plus | BSD-3-Clause |

Flutter and the Dart SDK are BSD-3-Clause (© The Flutter Authors, © the Dart
project authors).

## Icon

The application icon in `assets/icon/` is original work by the author and is
covered by the project's MIT license along with the rest of the repository.
