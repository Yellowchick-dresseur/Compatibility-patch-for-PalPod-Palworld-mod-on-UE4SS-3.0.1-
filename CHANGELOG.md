# Changelog

## v1.2.0 (2026-05-04) - "Nexus-ready" release

### Strategy change
- 🔄 **100% legal release**: removed automatic modification of PalPod's `main.lua`
- 📋 The installer now **detects** the BOM and `tostring()` issues but only **informs** the user — it does not patch the file unless the user runs the OPTIONAL helper script themselves
- 📦 New `optional/manual_main_lua_fix/` folder with detailed manual instructions and an opt-in helper

### Why the change?
PalPod's terms don't allow modifying it without permission. This release respects that 100%.
Users with the `main.lua` bug get clear instructions on how to fix it manually, plus an optional helper if they want it.

### What stayed
- All other features from v1.1.0 are intact:
  - Auto-detect Steam Palworld
  - Auto-detect UE4SS structure
  - Move PalPod to the correct folder
  - Clean `mods.txt` duplicates
  - Install PalPodFix companion mod (F8 = diagnostics)
  - Rename `.mp3` to `.wav` in Music folder

### Other
- 📝 New `NEXUS_PAGE_CONTENT.txt` with ready-to-paste mod page text
- 📝 Improved README and clearer language
- 🌐 English-first (was French/English mixed)

## v1.1.0 (2026-05-03)

- Added `.mp3` → `.wav` automatic renaming
- Added `tostring()` fix for `AddFileToFileList`
- Backup of original `main.lua` before modification

## v1.0.0 (2026-05-03)

- Initial release: BOM removal, mods.txt cleanup, structure migration
