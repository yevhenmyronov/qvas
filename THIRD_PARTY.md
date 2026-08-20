# Third-party notices

QVAS itself is MIT-licensed (see [LICENSE](LICENSE)).

## Fonts

| Font | License | Source |
|---|---|---|
| Inter | OFL 1.1 — [Inter-OFL.txt](assets/fonts/Inter-OFL.txt) | [rsms/inter](https://github.com/rsms/inter) |
| Noto Color Emoji | OFL 1.1 — [NotoColorEmoji-OFL.txt](assets/fonts/NotoColorEmoji-OFL.txt) | [google/fonts](https://github.com/google/fonts/tree/main/ofl/notocoloremoji) |

Both ship **modified** — subsets holding only the glyphs the app draws, which is
why the emoji font is 264 KB instead of 2.9 MB. Neither upstream declares a
Reserved Font Name, so the subsets keep the original family names. The license
texts ship inside the APK and appear under Settings → Licenses; this file only
reaches whoever opens the repository. Subsetting scripts:
[`build_inter_subset.py`](tool/build_inter_subset.py),
[`build_emoji_font.py`](tool/build_emoji_font.py).

## Packages

MIT: `flutter_riverpod`, `drift`, `drift_flutter`, `uuid`, `file_picker`.
BSD-3-Clause: `path_provider`, `intl`, `share_plus`, and Flutter and the Dart SDK
themselves. Resolved versions are in [`pubspec.lock`](pubspec.lock).

## Icon

Original work by the author, covered by the project's MIT license.
