@echo off
setlocal enabledelayedexpansion

rem Close AutoHotkey instances
echo Closing AutoHotkey instances...
taskkill /IM AutoHotkeyU64.exe /F 2>nul
taskkill /IM AutoHotkey64.exe /F 2>nul

rem Find most recent Steam account
set "steamPath=D:\Games\Steam\config\loginusers.vdf"
if not exist "%steamPath%" (
    echo Steam config file not found!
    pause
    exit /b 1
)

echo Parsing Steam config file...
set "mostRecentAccount="
set "currentAccount="
set "isMostRecent="

rem Parse the VDF file more carefully
for /F "usebackq delims=" %%A in ("%steamPath%") do (
    set "line=%%A"
    
    rem Remove quotes and trim whitespace
    set "line=!line:"=!"
    set "line=!line:	= !"
    for /F "tokens=*" %%L in ("!line!") do set "line=%%L"
    
    rem Check for AccountName line
    echo !line! | findstr /I /C:"AccountName" >nul
    if !errorlevel! equ 0 (
        for /F "tokens=2*" %%B in ("!line!") do set "currentAccount=%%B"
    )
    
    rem Check for MostRecent line with value 1
    echo !line! | findstr /I /C:"MostRecent" | findstr /C:"1" >nul
    if !errorlevel! equ 0 (
        if not "!currentAccount!"=="" (
            set "mostRecentAccount=!currentAccount!"
        )
    )
)

rem Debug output
echo Debug: Most recent account found: [!mostRecentAccount!]

rem Check account and launch
if not "!mostRecentAccount!"=="" (
    if /I "!mostRecentAccount!"=="walkedgibbons" (
        echo Launching Call of Duty HQ...
        start "" "steam://rungameid/1938090"
        echo Done!
    ) else (
        echo Wrong account! Please switch to walkedgibbons account.
        echo Current account: !mostRecentAccount!
    )
) else (
    echo Could not determine the most recent account.
    echo Please check the Steam config file format.
)

timeout /t 5 /nobreak >nul