# PalPodFix v1.2.0 — Compatibility Patch for PalPod

A community-made compatibility patch that helps [PalPod by Zurr](https://www.nexusmods.com/palworld/mods/999) work properly with the latest UE4SS (3.0.1+) on Steam.

## ⚠️ This patch does NOT include or modify PalPod's files

This is a **separate companion mod** that:
- Helps you configure your local installation
- Adds a diagnostic companion mod
- Renames `.mp3` to `.wav` in your music folder (if you opt in)

It does **not** redistribute, replace, or modify any of PalPod's code. PalPod is the sole property of **Zurr**, all credit for the music player goes to them. You must install PalPod yourself first.

If your PalPod's `main.lua` has issues, this patch will **detect** them and **tell you how to fix manually** — but won't touch the file unless you explicitly run the optional helper.

## What this patch does (7 steps + 1 optional)

The included installer:

1. ✅ **Detects** your Steam Palworld installation
2. ✅ **Detects** your UE4SS version (3.0.1+ or legacy)
3. ✅ **Moves PalPod** to the right folder for your UE4SS version (your local copy)
4. ✅ **Diagnoses** PalPod's `main.lua` for the two known issues — does NOT modify
5. ✅ **Cleans** duplicates in `mods.txt`
6. ✅ **Installs PalPodFix** companion mod (F8 hotkey for in-game diagnostics)
7. ✅ **Renames `.mp3` to `.wav`** in YOUR Music folder (with your permission)

Plus an **optional** standalone helper (`optional/manual_main_lua_fix/`) you can run yourself if you want to apply the `main.lua` fixes automatically on your local PalPod copy.

## Installation

1. Install [UE4SS 3.0.1+](https://github.com/UE4SS-RE/RE-UE4SS/releases)
2. Install [PalPod](https://www.nexusmods.com/palworld/mods/999) — the actual music player
3. Run `Installer.bat` from this archive
4. The installer walks you through everything

## In-game controls

| Key | Action |
|-----|--------|
| `N`  | Open/close PalPod menu (PalPod's own binding) |
| `O`  | Toggle playback (PalPod's own binding) |
| `F8` | **NEW** — Show PalPodFix diagnostics in console |

## Adding your music

PalPod **only reads `.wav` files**.

If you have MP3 files, convert them with any tool (online converter, Audacity, ffmpeg, etc.):
```
ffmpeg -i input.mp3 -acodec pcm_s16le -ar 44100 -ac 2 output.wav
```

If your "MP3" files are actually WAV format internally (some sources output this), the installer's Step 7 can rename them — but a true MP3 needs to be re-encoded, not just renamed.

Drop your `.wav` files in:
```
Pal\Content\Paks\LogicMods\PalPodData\Music\
```

Then in-game: open PalPod (N) → Refresh → your tracks appear.

## Known issues

- **Random/Shuffle and Loop modes** are buggy in PalPod's Blueprint and cannot be fixed by a Lua patch. Sequential playback works fine.
- **Game Pass version** is not supported (Steam only)
- This patch detects the `main.lua` BOM/tostring bug but won't auto-fix it without your explicit consent (legal compliance).

## Troubleshooting

1. **Press F8 in-game** to see live diagnostics in the UE4SS console
2. Verify `Pal\Content\Paks\LogicMods\PalPodData\Music\` contains `.wav` files (not `.mp3`)
3. The installer is safe to re-run as many times as needed
4. Verify `mods.txt` contains `PalPod : 1` and `PalPodFix : 1`
5. If PalPod still doesn't load, check the `optional/manual_main_lua_fix/README.txt`

## Credits

- **PalPod** — original mod by [Zurr](https://www.nexusmods.com/palworld/mods/999) (this patch is unaffiliated)
- **UE4SS** — by the UE4SS-RE team
- This patch is **independent**, contains **no PalPod code or assets**

## License

This patch is released under the MIT License (see LICENSE.txt). PalPod itself remains under its original author's terms.

## Source code

The patch is fully open source. Inspect `LANCER_INSTALLATION.ps1` and `PalPodFix\Scripts\main.lua` to verify what it does. Nothing is obfuscated.

## Changelog

### v1.2.0
- 🔄 **Stratégie 100% legal**: removed automatic `main.lua` modification
- ✨ Added `optional/manual_main_lua_fix/` for users who want to apply the fix
- 📝 Improved diagnostics that detect issues without auto-fixing them
- 📝 Clearer language about what is and isn't modified

### v1.1.0
- Added `.mp3` → `.wav` automatic renaming
- Added `tostring()` fix for `AddFileToFileList`
- Backup of original `main.lua` before modification

### v1.0.0
- Initial release: BOM removal, mods.txt cleanup, structure migration

---

**Disclaimer**: This patch is **unofficial** and not endorsed by Zurr. If Zurr requests removal, the patch will be taken down immediately. Zurr is welcome to use any of these ideas in an official PalPod update.
