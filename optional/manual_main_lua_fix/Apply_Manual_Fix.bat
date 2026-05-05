@echo off
chcp 1252 >nul
title PalPodFix - Manual main.lua fix

set "PS1=%~dp0Apply_Manual_Fix.ps1"

if not exist "%PS1%" (
    echo  [ERROR] Apply_Manual_Fix.ps1 not found.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
