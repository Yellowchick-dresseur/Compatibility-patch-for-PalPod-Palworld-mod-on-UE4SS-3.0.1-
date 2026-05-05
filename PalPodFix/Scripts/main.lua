-- ============================================================
--  PalPodFix v1.2.0 - Companion mod for PalPod
--
--  Author : Community
--  License: MIT
--
--  This is an INDEPENDENT mod that complements PalPod.
--  It does NOT modify, replace, or include any PalPod code.
--  PalPod is the property of Zurr. All credit for the music
--  player itself goes to them.
--
--  What this mod does:
--    - Diagnoses common installation issues (F8 hotkey)
--    - Watches the Music folder and warns about .mp3 files
--    - Provides clear log output for troubleshooting
-- ============================================================

local MOD_NAME = "PalPodFix"
local MOD_VERSION = "1.2.0"

local function log(msg)
    print("[" .. MOD_NAME .. "] " .. tostring(msg) .. "\n")
end

log("===================================================")
log("PalPodFix v" .. MOD_VERSION .. " loaded")
log("Companion mod for PalPod by Zurr")
log("===================================================")

-- ============================================================
-- DIAGNOSTIC FUNCTION
-- ============================================================
local function CheckMusicFolder()
    -- The working directory under UE4SS 3.0.1+ is Pal\Binaries\Win64\ue4ss\
    -- so the Music folder is at this relative path
    local musicPath = "..\\..\\Content\\Paks\\LogicMods\\PalPodData\\Music"

    local pipe = io.popen('if exist "'..musicPath..'" (echo OK) else (echo MISSING)')
    if not pipe then
        log("[ERROR] Cannot run shell command")
        return
    end
    local result = pipe:read("*a"):gsub("%s+", "")
    pipe:close()

    if result ~= "OK" then
        log("[ERROR] PalPodData\\Music folder NOT found.")
        log("        Make sure PalPod is installed first:")
        log("        https://www.nexusmods.com/palworld/mods/999")
        return
    end

    log("[OK] PalPodData\\Music folder found.")

    local wavCount = 0
    local mp3Count = 0
    local p = io.popen('dir /b "'..musicPath..'\\*.wav" 2>nul')
    if p then
        for _ in p:lines() do wavCount = wavCount + 1 end
        p:close()
    end
    local p2 = io.popen('dir /b "'..musicPath..'\\*.mp3" 2>nul')
    if p2 then
        for _ in p2:lines() do mp3Count = mp3Count + 1 end
        p2:close()
    end

    log("[OK] " .. wavCount .. " .wav file(s) found in Music folder")

    if mp3Count > 0 then
        log("")
        log("[WARN] " .. mp3Count .. " .mp3 file(s) detected.")
        log("       PalPod ONLY reads .wav files. Your .mp3 will be ignored.")
        log("       Solution: Convert them to .wav (or rename if already WAV format).")
        log("       See README.md for instructions.")
        log("")
    end

    if wavCount == 0 and mp3Count == 0 then
        log("[INFO] No music files found yet.")
        log("       Drop your .wav files in the Music folder, then click")
        log("       Refresh in PalPod's menu (press N in-game).")
    end
end

CheckMusicFolder()

-- ============================================================
-- F8 HOTKEY: ON-DEMAND DIAGNOSTIC
-- ============================================================
local function safeBind(keyName, keyValue, callback)
    local ok, err = pcall(function()
        RegisterKeyBind(keyValue, callback)
    end)
    if ok then
        log("Hotkey " .. keyName .. " registered for diagnostics.")
    else
        log("Failed to register " .. keyName .. ": " .. tostring(err))
    end
end

safeBind("F8", Key.F8, function()
    log("=== F8 Diagnostic ===")
    CheckMusicFolder()

    -- Show mods.txt entries for PalPod
    local pipe = io.popen('type "ue4ss\\Mods\\mods.txt" 2>nul')
    if pipe then
        log("--- mods.txt PalPod entries ---")
        for line in pipe:lines() do
            if line:match("PalPod") then
                log("  " .. line)
            end
        end
        pipe:close()
    end
    log("=== End Diagnostic ===")
end)

log("Patch active. Press F8 in-game for live diagnostics.")
log("PalPod controls: N=Open menu, O=Toggle playback (unchanged)")
