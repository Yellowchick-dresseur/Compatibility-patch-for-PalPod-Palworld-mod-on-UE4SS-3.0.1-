@echo off
chcp 1252 >nul
title PalPodFix v1.2.0 - Installer

set "PS1=%~dp0LANCER_INSTALLATION.ps1"

if not exist "%PS1%" (
    echo  [ERROR] LANCER_INSTALLATION.ps1 not found.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
