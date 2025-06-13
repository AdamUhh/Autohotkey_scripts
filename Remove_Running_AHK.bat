@echo off
setlocal enabledelayedexpansion

rem Close all running AutoHotkeyU64 instances
tasklist /FI "IMAGENAME eq AutoHotkeyU64.exe" | find /I "AutoHotkeyU64.exe" > nul
if %errorlevel%==0 (
    echo Closing all running AutoHotkeyU64 instances...
    taskkill /IM AutoHotkeyU64.exe /F
    if %errorlevel%==0 (
        echo Successfully closed all instances.
    ) else (
        echo ERROR: Failed to close instances of AutoHotkeyU64.exe.
    )
) else (
    echo No running AutoHotkeyU64 instances found.
)

rem Close all running AutoHotkey64 instances
tasklist /FI "IMAGENAME eq AutoHotkey64.exe" | find /I "AutoHotkey64.exe" > nul
if %errorlevel%==0 (
    echo Closing all running AutoHotkey64 instances...
    taskkill /IM AutoHotkey64.exe /F
    if %errorlevel%==0 (
        echo Successfully closed all instances.
    ) else (
        echo ERROR: Failed to close instances of AutoHotkey64.exe.
    )
) else (
    echo No running AutoHotkeyU64 instances found.
)

echo .
echo Done!
