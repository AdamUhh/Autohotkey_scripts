@echo off
setlocal enabledelayedexpansion

rem Close AutoHotkey instances
echo Closing AutoHotkey instances...
taskkill /IM AutoHotkeyU64.exe /F 2>nul
taskkill /IM AutoHotkey64.exe /F 2>nul

