============================================================
 OPTIONAL: Manual fix for PalPod's main.lua
============================================================

 This folder is OPTIONAL. The main installer does NOT modify
 PalPod's files for legal reasons (PalPod is the property of
 its author Zurr).

 If you have one or both of these issues:

   1. UTF-8 BOM at start of main.lua (causes Lua crash)
   2. Missing tostring() in AddFileToFileList call
      (causes "bad conversion" errors on UE4SS 3.0.1+)

 ...you can fix them yourself in two ways:

============================================================
 OPTION A - Manual edit (recommended for transparency)
============================================================

 Open this file in a text editor (Notepad++ recommended):

   <Palworld>\Pal\Binaries\Win64\ue4ss\Mods\PalPod\scripts\main.lua

 Apply these changes:

 1. REMOVE THE UTF-8 BOM
    - In Notepad++ : Encoding menu -> Convert to UTF-8 (without BOM)
    - Then save the file

 2. ADD tostring() AROUND filename
    Find this line:
      ModActor:AddFileToFileList(filename)

    Replace it with:
      ModActor:AddFileToFileList(tostring(filename))

 3. Save and relaunch Palworld.

============================================================
 OPTION B - Automated helper script (your responsibility)
============================================================

 If you trust this patch's code, you can run:

   Apply_Manual_Fix.bat

 ...which will apply the two fixes above on YOUR LOCAL copy
 of PalPod's main.lua. The original file is backed up first
 (as main.lua.original.backup).

 By running this script you acknowledge that you are
 modifying your own local installation of PalPod, on your
 own machine, for personal use only.

 The script does NOT redistribute or share PalPod's code.

============================================================
 WHY IS THIS OPTIONAL ?
============================================================

 PalPod is the creative work of Zurr. Modifying or
 redistributing his files without permission is not okay.
 By keeping this fix as an OPTIONAL local-only operation
 that YOU choose to run, this patch stays 100% legal.

 If Zurr publishes an updated version of PalPod with these
 fixes built-in, you won't need this folder anymore.

============================================================
