# ============================================================
#  Apply_Manual_Fix.ps1
#
#  OPTIONAL helper that applies the two known fixes to YOUR
#  LOCAL copy of PalPod's main.lua. By running this you
#  acknowledge that you are modifying your own installation
#  for personal use.
#
#  The script:
#    - Backs up main.lua as main.lua.original.backup
#    - Removes UTF-8 BOM if present
#    - Adds tostring() around the filename argument
#  It does NOT redistribute any PalPod code anywhere.
# ============================================================

$Host.UI.RawUI.WindowTitle = "PalPodFix - Manual main.lua fix"
$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "  ====================================================="
Write-Host "   Manual main.lua fix for PalPod"
Write-Host "  ====================================================="
Write-Host ""
Write-Host "   This will modify YOUR LOCAL copy of PalPod's main.lua"
Write-Host "   to fix two known compatibility issues."
Write-Host ""
Write-Host "   The original file will be backed up first."
Write-Host ""
$confirm = Read-Host "   Continue ? (Y/N)"
if ($confirm -notmatch "^[oOyY]") {
    Write-Host "   Cancelled."
    Read-Host "   Press Enter to exit"
    exit 0
}

# Detect Palworld
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
    $PalworldPath = (Read-Host "  Palworld install path").Trim('"')
}

# Locate main.lua
$PalPodLua = $null
foreach ($subdir in @("scripts", "Scripts")) {
    $tryPath = Join-Path $PalworldPath "Pal\Binaries\Win64\ue4ss\Mods\PalPod\$subdir\main.lua"
    if (Test-Path $tryPath) {
        $PalPodLua = $tryPath
        break
    }
    # Also try legacy structure
    $tryPath = Join-Path $PalworldPath "Pal\Binaries\Win64\Mods\PalPod\$subdir\main.lua"
    if (Test-Path $tryPath) {
        $PalPodLua = $tryPath
        break
    }
}

if (-not $PalPodLua) {
    Write-Host "  [ERROR] Could not find PalPod's main.lua. Is PalPod installed ?"
    Read-Host "  Press Enter to exit"
    exit 1
}

Write-Host "  [OK] Found: $PalPodLua"

# Backup
$backup = "$PalPodLua.original.backup"
if (-not (Test-Path $backup)) {
    Copy-Item -Path $PalPodLua -Destination $backup -Force
    Write-Host "  [OK] Original backed up as: main.lua.original.backup"
} else {
    Write-Host "  [INFO] Backup already exists, keeping the existing one."
}

# Read content
$bytes = [System.IO.File]::ReadAllBytes($PalPodLua)

# Remove BOM if present
$startOffset = 0
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "  [FIX 1] Removing UTF-8 BOM..."
    $startOffset = 3
} else {
    Write-Host "  [OK] No BOM detected."
}

# Decode and apply tostring fix
$content = [System.Text.Encoding]::UTF8.GetString($bytes, $startOffset, $bytes.Length - $startOffset)

if ($content -match "AddFileToFileList\s*\(\s*filename\s*\)") {
    Write-Host "  [FIX 2] Adding tostring() to AddFileToFileList..."
    $content = $content -replace "AddFileToFileList\s*\(\s*filename\s*\)", "AddFileToFileList(tostring(filename))"
} else {
    Write-Host "  [OK] tostring() already present or different code structure."
}

# Write back as ASCII (no BOM)
# Note: this is safe because the patched code only contains ASCII characters
[System.IO.File]::WriteAllText($PalPodLua, $content, [System.Text.Encoding]::ASCII)

# Verify no BOM in result
$verifyBytes = [System.IO.File]::ReadAllBytes($PalPodLua) | Select-Object -First 3
if ($verifyBytes[0] -eq 0xEF -and $verifyBytes[1] -eq 0xBB -and $verifyBytes[2] -eq 0xBF) {
    Write-Host "  [WARN] BOM still detected after fix !"
} else {
    Write-Host "  [OK] File written without BOM."
}

Write-Host ""
Write-Host "  ====================================================="
Write-Host "   Manual fix applied !"
Write-Host "  ====================================================="
Write-Host ""
Write-Host "   You can restore the original anytime by copying"
Write-Host "   main.lua.original.backup over main.lua"
Write-Host ""
Read-Host "  Press Enter to exit"
