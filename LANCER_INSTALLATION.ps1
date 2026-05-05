# ============================================================
#  PalPodFix v1.2.0 - Installer (100% legal version)
#  Compatibility helper for PalPod (by Zurr) on UE4SS 3.0.1+
#
#  This installer does NOT modify, copy, or redistribute
#  any PalPod files. It only:
#    1. Detects your Palworld installation
#    2. Detects your UE4SS version
#    3. Helps you move PalPod to the correct folder
#       (the user's own copy, on the user's own machine)
#    4. Cleans your local mods.txt
#    5. Installs PalPodFix (companion mod)
#    6. Renames .mp3 to .wav in YOUR Music folder
#    7. Detects (but does NOT fix) the main.lua bug
#       and tells you how to fix it manually
# ============================================================

$Host.UI.RawUI.WindowTitle = "PalPodFix v1.2.0 - Installer"
$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "  ====================================================="
Write-Host "   PalPodFix v1.2.0 - Companion Patch for PalPod"
Write-Host "   Original PalPod by Zurr (mod #999 on Nexus)"
Write-Host "  ====================================================="
Write-Host ""
Write-Host "   This installer does NOT modify or include any"
Write-Host "   PalPod files. It only helps configure your local"
Write-Host "   installation and adds a diagnostic companion mod."
Write-Host ""

# ============================================================
# STEP 1: DETECT PALWORLD (Steam)
# ============================================================
Write-Host "  === Step 1/7: Detecting Palworld ==="

$pathsToTest = @(
    "C:\Program Files (x86)\Steam\steamapps\common\Palworld",
    "C:\Program Files\Steam\steamapps\common\Palworld",
    "D:\Steam\steamapps\common\Palworld",
    "D:\SteamLibrary\steamapps\common\Palworld",
    "E:\Steam\steamapps\common\Palworld",
    "E:\SteamLibrary\steamapps\common\Palworld",
    "F:\Steam\steamapps\common\Palworld",
    "F:\SteamLibrary\steamapps\common\Palworld"
)

$PalworldPath = $null
foreach ($p in $pathsToTest) {
    if (Test-Path (Join-Path $p "Pal\Binaries\Win64\Palworld-Win64-Shipping.exe")) {
        $PalworldPath = $p
        break
    }
}

if (-not $PalworldPath) {
    Write-Host "  [!] Palworld not auto-detected. Please enter your install path:"
    $PalworldPath = (Read-Host "  Path").Trim('"')
}

if (-not (Test-Path (Join-Path $PalworldPath "Pal\Binaries\Win64\Palworld-Win64-Shipping.exe"))) {
    Write-Host "  [ERROR] Palworld not found at: $PalworldPath"
    Read-Host "  Press Enter to exit"
    exit 1
}
Write-Host "  [OK] Palworld found: $PalworldPath"

# ============================================================
# STEP 2: DETECT UE4SS
# ============================================================
Write-Host ""
Write-Host "  === Step 2/7: Detecting UE4SS ==="

$Win64       = Join-Path $PalworldPath "Pal\Binaries\Win64"
$NewModsDir  = Join-Path $Win64 "ue4ss\Mods"
$OldModsDir  = Join-Path $Win64 "Mods"
$NewSettings = Join-Path $Win64 "ue4ss\UE4SS-settings.ini"
$OldSettings = Join-Path $Win64 "UE4SS-settings.ini"

$ModsDir = $null
$SettingsFile = $null
if (Test-Path $NewSettings) {
    $ModsDir = $NewModsDir
    $SettingsFile = $NewSettings
    Write-Host "  [OK] UE4SS detected (3.0.1+ structure)"
} elseif (Test-Path $OldSettings) {
    $ModsDir = $OldModsDir
    $SettingsFile = $OldSettings
    Write-Host "  [OK] UE4SS detected (legacy structure)"
} else {
    Write-Host ""
    Write-Host "  [ERROR] UE4SS is not installed."
    Write-Host "  Get UE4SS at:"
    Write-Host "    https://github.com/UE4SS-RE/RE-UE4SS/releases"
    Read-Host "  Press Enter to exit"
    exit 1
}

# ============================================================
# STEP 3: MOVE PALPOD TO CORRECT FOLDER (user's own copy)
# ============================================================
Write-Host ""
Write-Host "  === Step 3/7: Checking PalPod location ==="

$PalPodOldPath = Join-Path $OldModsDir "PalPod"
$PalPodNewPath = Join-Path $NewModsDir "PalPod"

if ((Test-Path $PalPodOldPath) -and ($ModsDir -eq $NewModsDir)) {
    Write-Host "  [!] Your PalPod is in the legacy folder."
    Write-Host "      Moving from: $PalPodOldPath"
    Write-Host "      To:          $PalPodNewPath"

    if (Test-Path $PalPodNewPath) {
        Write-Host "  [INFO] Destination already exists, removing old copy..."
        Remove-Item -Recurse -Force $PalPodOldPath
    } else {
        Move-Item -Path $PalPodOldPath -Destination $PalPodNewPath -Force
        Write-Host "  [OK] PalPod moved to the correct folder."
    }
} elseif (Test-Path $PalPodNewPath) {
    Write-Host "  [OK] PalPod is already in the correct folder."
} else {
    Write-Host ""
    Write-Host "  [ATTENTION] PalPod is not installed!"
    Write-Host "      Download it from:"
    Write-Host "      https://www.nexusmods.com/palworld/mods/999"
    Write-Host "      Install PalPod FIRST, then run this installer again."
    Read-Host "  Press Enter to exit"
    exit 1
}

# ============================================================
# STEP 4: DETECT main.lua ISSUES (do NOT modify - just inform)
# ============================================================
Write-Host ""
Write-Host "  === Step 4/7: Diagnosing PalPod's main.lua ==="

$PalPodLua = $null
foreach ($subdir in @("scripts", "Scripts")) {
    $tryPath = Join-Path $PalPodNewPath "$subdir\main.lua"
    if (Test-Path $tryPath) {
        $PalPodLua = $tryPath
        break
    }
}

$bomDetected = $false
$tostringMissing = $false

if ($PalPodLua) {
    # Check for UTF-8 BOM (causes Lua to crash)
    $bytes = [System.IO.File]::ReadAllBytes($PalPodLua)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bomDetected = $true
    }

    # Check for AddFileToFileList without tostring()
    $luaContent = [System.IO.File]::ReadAllText($PalPodLua)
    if ($luaContent -match "AddFileToFileList\s*\(\s*filename\s*\)") {
        $tostringMissing = $true
    }

    if (-not $bomDetected -and -not $tostringMissing) {
        Write-Host "  [OK] PalPod's main.lua looks fine."
    } else {
        Write-Host ""
        Write-Host "  [!] Detected issues in your PalPod's main.lua:"
        if ($bomDetected) {
            Write-Host "      - UTF-8 BOM at start of file (will cause Lua crash)"
        }
        if ($tostringMissing) {
            Write-Host "      - Missing tostring() in AddFileToFileList call"
            Write-Host "        (this causes 'bad conversion' errors on UE4SS 3.0.1+)"
        }
        Write-Host ""
        Write-Host "  This installer does NOT modify PalPod's files."
        Write-Host ""
        Write-Host "  To fix manually, see:"
        Write-Host "    optional\manual_main_lua_fix\README.txt"
        Write-Host ""
        Write-Host "  Or you can run the optional helper script (you take"
        Write-Host "  responsibility for the local modification):"
        Write-Host "    optional\manual_main_lua_fix\Apply_Manual_Fix.bat"
        Write-Host ""
    }
} else {
    Write-Host "  [WARN] Could not find PalPod's main.lua to inspect."
}

# ============================================================
# STEP 5: CLEAN mods.txt DUPLICATES
# ============================================================
Write-Host ""
Write-Host "  === Step 5/7: Cleaning mods.txt ==="

$ModsTxt = Join-Path $ModsDir "mods.txt"
if (Test-Path $ModsTxt) {
    $content = Get-Content $ModsTxt
    $unique = @()
    $seen = @{}
    $duplicatesRemoved = 0

    foreach ($line in $content) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith(";")) {
            $unique += $line
            continue
        }
        $key = $trimmed.ToLower()
        if ($seen.ContainsKey($key)) {
            $duplicatesRemoved++
        } else {
            $unique += $line
            $seen[$key] = $true
        }
    }

    if ($duplicatesRemoved -gt 0) {
        $unique | Set-Content -Path $ModsTxt -Encoding ASCII
        Write-Host "  [OK] Removed $duplicatesRemoved duplicate(s) from mods.txt"
    } else {
        Write-Host "  [OK] No duplicates in mods.txt"
    }
}

# ============================================================
# STEP 6: INSTALL PALPODFIX + ACTIVATE
# ============================================================
Write-Host ""
Write-Host "  === Step 6/7: Installing PalPodFix ==="

$ModSource = Join-Path $ScriptDir "PalPodFix"
$ModDest   = Join-Path $ModsDir "PalPodFix"

if (-not (Test-Path $ModSource)) {
    Write-Host "  [ERROR] PalPodFix source folder not found next to script."
    Read-Host "  Press Enter to exit"
    exit 1
}

if (Test-Path $ModDest) {
    Write-Host "  [INFO] Updating existing PalPodFix..."
    Remove-Item -Recurse -Force $ModDest
}
Copy-Item -Path $ModSource -Destination $ModsDir -Recurse -Force
Write-Host "  [OK] PalPodFix installed"

# Activate both mods in mods.txt
$content = Get-Content -Path $ModsTxt -ErrorAction SilentlyContinue
foreach ($modName in @("PalPod", "PalPodFix")) {
    $alreadyActive = $false
    if ($content) {
        foreach ($line in $content) {
            if ($line -match "^\s*$modName\s*:\s*1\s*$") {
                $alreadyActive = $true
                break
            }
        }
    }
    if (-not $alreadyActive) {
        Add-Content -Path $ModsTxt -Value "$modName : 1" -Encoding ASCII
        Write-Host "  [OK] $modName activated in mods.txt"
    } else {
        Write-Host "  [OK] $modName already active"
    }
}

# ============================================================
# STEP 7: HANDLE MUSIC FILES (rename .mp3 to .wav, copy from MP3_Input)
# ============================================================
Write-Host ""
Write-Host "  === Step 7/7: Handling music files ==="

$MusicSrc = Join-Path $ScriptDir "MP3_Input"
$MusicDst = Join-Path $PalworldPath "Pal\Content\Paks\LogicMods\PalPodData\Music"

if (-not (Test-Path $MusicDst)) {
    Write-Host "  [INFO] Creating PalPod's Music folder..."
    New-Item -ItemType Directory -Path $MusicDst -Force | Out-Null
}

# Copy WAV files from MP3_Input/ if any
$wavFiles = Get-ChildItem -LiteralPath $MusicSrc -Filter "*.wav" -ErrorAction SilentlyContinue
if ($wavFiles -and $wavFiles.Count -gt 0) {
    Write-Host "  [INFO] Copying $($wavFiles.Count) WAV file(s) from MP3_Input\..."
    foreach ($wav in $wavFiles) {
        Copy-Item -Path $wav.FullName -Destination $MusicDst -Force
    }
}

# Rename .mp3 to .wav (PalPod only reads .wav)
# This is YOUR local file, so renaming is your choice
$mp3Files = Get-ChildItem -LiteralPath $MusicDst -Filter "*.mp3" -ErrorAction SilentlyContinue
if ($mp3Files -and $mp3Files.Count -gt 0) {
    Write-Host "  [!] Found $($mp3Files.Count) .mp3 file(s) in your Music folder."
    Write-Host "      PalPod only reads .wav extensions."
    $rename = Read-Host "  Rename them to .wav ? (Y/N)"
    if ($rename -match "^[oOyY]") {
        $renamed = 0
        foreach ($mp3 in $mp3Files) {
            $newName = $mp3.BaseName + ".wav"
            $newPath = Join-Path $MusicDst $newName
            if (Test-Path $newPath) {
                Write-Host "    [SKIP] $newName already exists"
            } else {
                Rename-Item -LiteralPath $mp3.FullName -NewName $newName
                $renamed++
            }
        }
        Write-Host "  [OK] Renamed $renamed file(s)"
        Write-Host "  [WARN] If a renamed file is actually MP3 (not WAV inside)"
        Write-Host "         it won't play. Use a real conversion tool then."
    } else {
        Write-Host "  [INFO] Skipped renaming. Your .mp3 files won't be visible to PalPod."
    }
}

$wavFinal = Get-ChildItem -LiteralPath $MusicDst -Filter "*.wav" -ErrorAction SilentlyContinue
$wavCount = if ($wavFinal) { $wavFinal.Count } else { 0 }
Write-Host "  [OK] $wavCount .wav file(s) ready for PalPod"

# ============================================================
# OPTION: ENABLE UE4SS CONSOLE
# ============================================================
Write-Host ""
$enableConsole = Read-Host "  Enable UE4SS console for log viewing ? (Y/N)"
if ($enableConsole -match "^[oOyY]") {
    $settings = Get-Content -Path $SettingsFile -Raw
    $settings = $settings -replace "GuiConsoleVisible\s*=\s*0", "GuiConsoleVisible = 1"
    $settings = $settings -replace "GuiConsoleEnabled\s*=\s*0", "GuiConsoleEnabled = 1"
    $settings = $settings -replace "ConsoleEnabled\s*=\s*0",    "ConsoleEnabled = 1"
    Set-Content -Path $SettingsFile -Value $settings -Encoding ASCII
    Write-Host "  [OK] UE4SS console enabled."
}

# ============================================================
# FINAL SUMMARY
# ============================================================
Write-Host ""
Write-Host "  ====================================================="
Write-Host "   PalPodFix v1.2.0 install complete !"
Write-Host "  ====================================================="
Write-Host ""
Write-Host "  Applied fixes (your local installation only):"
Write-Host "    [v] PalPod relocated to correct UE4SS structure"
Write-Host "    [v] mods.txt cleaned and activated"
Write-Host "    [v] PalPodFix companion installed (F8 = diagnostic)"
Write-Host "    [v] .mp3 -> .wav renaming (if you opted in)"
Write-Host ""

if ($bomDetected -or $tostringMissing) {
    Write-Host "  IMPORTANT - Manual action needed for PalPod's main.lua :"
    if ($bomDetected) {
        Write-Host "    - Remove the UTF-8 BOM from main.lua"
    }
    if ($tostringMissing) {
        Write-Host "    - Wrap filename in tostring() inside AddFileToFileList"
    }
    Write-Host "    See: optional\manual_main_lua_fix\README.txt"
    Write-Host ""
}

Write-Host "  In game:"
Write-Host "    - Press N to open PalPod menu"
Write-Host "    - Click Refresh to scan music files"
Write-Host "    - Press F8 for PalPodFix diagnostics"
Write-Host ""
Write-Host "  To add more music later:"
Write-Host "    Drop .wav files in:"
Write-Host "    $MusicDst"
Write-Host ""

Read-Host "  Press Enter to exit"
