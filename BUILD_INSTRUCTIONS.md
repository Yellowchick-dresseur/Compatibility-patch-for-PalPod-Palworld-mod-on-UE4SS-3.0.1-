# BUILD_INSTRUCTIONS.md — For Nexus Mods Moderators

This document explains how to inspect, verify, and rebuild PalPodFix from source. It is intended for Nexus Mods moderators reviewing this mod for security purposes.

## Why this mod triggers virus scanners

PalPodFix is a Palworld mod compatibility helper that automates several local installation tasks. The combination of these operations triggers antivirus heuristics, even though every operation is benign:

| Operation | Why AV flags it | Why it's safe here |
|-----------|-----------------|--------------------|
| `Move-Item` on Program Files folders | Used by some malware installers | Only operates on the user's own Palworld game folder, never system files |
| Rename `.mp3` → `.wav` in batch | Pattern resembles ransomware | Only renames files in `PalworldData/Music/` with explicit user consent (Y/N prompt) |
| `WriteAllBytes` to `.lua` files | Could be code injection | Optional, opt-in only (in `optional/manual_main_lua_fix/`), modifies user's own mod files |
| `.bat` launching `.ps1` | Common attack chain | Standard pattern for distributing PowerShell installers; script is not obfuscated |
| `-ExecutionPolicy Bypass` | Bypasses Windows security | Required because most users don't have execution policy set to allow scripts; standard for any PowerShell installer |

**The script makes no network connections. It does not download, upload, or transmit any data. It only manipulates files in the user's Palworld game folder.**

## Source code

All source code is available at:

**https://github.com/Yellowchick-dresseur/Compatibility-patch-for-PalPod-Palworld-mod-on-UE4SS-3.0.1-**

The repository contains the exact same files as the Nexus archive, plus this BUILD_INSTRUCTIONS.md file.

## Files included in the archive

```
PalPodFix_v1.2.0/
├── Installer.bat                          ← Launcher (calls PowerShell script)
├── LANCER_INSTALLATION.ps1                ← Main installer (PowerShell)
├── README.md                              ← User documentation
├── NEXUS_PAGE_CONTENT.txt                 ← Nexus page text
├── CHANGELOG.md                           ← Version history
├── LICENSE.txt                            ← MIT License
├── info.json                              ← Vortex metadata
├── MP3_Input/                             ← Empty folder for users to drop WAV files
│   └── PUT_YOUR_WAV_HERE.txt              ← Instructions
├── PalPodFix/                             ← The actual Lua mod
│   ├── enabled.txt                        ← UE4SS activation flag (empty file)
│   └── Scripts/
│       └── main.lua                       ← Lua script (UE4SS mod)
└── optional/                              ← Opt-in advanced helper
    └── manual_main_lua_fix/
        ├── README.txt                     ← Manual fix instructions
        ├── Apply_Manual_Fix.bat           ← Optional helper launcher
        └── Apply_Manual_Fix.ps1           ← Optional helper script
```

## What each script does (line by line summary)

### LANCER_INSTALLATION.ps1 (main installer)

The script performs these operations **in order** on the local machine:

1. **Detect Palworld installation** — searches common Steam library paths for `Palworld-Win64-Shipping.exe`
2. **Detect UE4SS modding framework** — checks for `UE4SS-settings.ini` in two possible locations
3. **Move PalPod folder** — if PalPod is in the legacy `Mods\` folder, moves it to `ue4ss\Mods\` (the user's own files)
4. **Inspect (does NOT modify) PalPod's main.lua** — checks for known compatibility issues; informs user but does not fix
5. **Clean mods.txt** — removes duplicate lines from a UE4SS configuration file
6. **Install PalPodFix** — copies the `PalPodFix\` folder (Lua mod) into the user's mods directory
7. **Activate mods** — adds entries to UE4SS's `mods.txt` activation file
8. **Rename .mp3 → .wav** (optional, prompts user) — renames files in `PalworldData/Music/`

The script never:
- Connects to the internet
- Downloads anything
- Reads or modifies anything outside the Palworld game folder
- Executes external binaries (only built-in PowerShell cmdlets)
- Uses obfuscated code, encoded commands, or dynamic invocation

### main.lua (the Lua mod itself)

A simple UE4SS Lua mod that:
- Logs diagnostic information at game startup
- Registers an F8 hotkey for in-game diagnostics
- Counts WAV files in the Music folder
- Does NOT modify any game files at runtime

This Lua script is loaded by the UE4SS framework (a third-party Unreal Engine modding tool that the user must install separately). It runs inside the UE4SS sandbox.

## How to verify the source code

### Option A: Download the Nexus ZIP and inspect directly

1. Download the quarantined file (it should be visible to moderators)
2. Extract with any unzip tool — there are no nested archives
3. Open `LANCER_INSTALLATION.ps1` in any text editor (Notepad, VS Code, etc.)
4. The script is approximately 250 lines, fully readable, with comments

### Option B: View on GitHub

Browse the public GitHub repository at the URL above. Every file is identical to the Nexus archive.

### Option C: Run in a sandbox

The PowerShell script is safe to run on a clean Windows VM. It will fail gracefully if Palworld is not installed (the only thing it needs to find).

## How to "build" the mod

There is no compilation step. PalPodFix is distributed as plain text files (PowerShell, Lua, Markdown). To recreate the ZIP archive:

```powershell
# In the source folder, run:
Compress-Archive -Path PalPodFix_v1.2.0 -DestinationPath PalPodFix_v1.2.0.zip
```

That's it — there is nothing compiled, no binary code, no obfuscated content, no embedded executables.

## What this mod does NOT do

To address common security concerns explicitly:

- ❌ Does NOT make any network connections
- ❌ Does NOT download files
- ❌ Does NOT upload files
- ❌ Does NOT modify Windows system files
- ❌ Does NOT modify the registry
- ❌ Does NOT install services or scheduled tasks
- ❌ Does NOT collect telemetry or user data
- ❌ Does NOT contain encoded/obfuscated code
- ❌ Does NOT call external programs (only built-in PowerShell cmdlets)
- ❌ Does NOT include or redistribute any third-party copyrighted code (PalPod's code is NOT included; the optional fix script only modifies the user's own local copy)

## Contact

If you have any questions or need additional verification, please reach out via the Nexus support email or my Nexus profile.

Thank you for taking the time to review this mod!

— Yellowchick Dresseur
