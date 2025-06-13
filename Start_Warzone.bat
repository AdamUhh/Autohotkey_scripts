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

rem Define the path to the Steam configuration file
set "steamPath="D:\Games\Steam\config\loginusers.vdf"

rem Check if the loginusers.vdf file exists
if not exist "!steamPath!" (
    echo Steam configuration file not found.
    pause
)

set "mostRecentAccount="

rem Read the currently logged in accounts and their MostRecent status
for /F "tokens=1,* delims=	" %%A in ('findstr /C:"AccountName" /C:"MostRecent" "!steamPath!"') do (
    REM echo Found: %%A %%B
    if %%A=="MostRecent" (
        if %%B=="1" (
            set "mostRecentAccount=!prevAccount!"
        )
    ) else if %%A=="AccountName" (
        set "prevAccount=%%B"
    )
)

rem Display the most recent logged in account
if defined mostRecentAccount (
    echo.
    echo.
    echo The most recently logged-in Steam account is:        !mostRecentAccount!
    echo.
    echo.
) else (
    echo.
    echo No active Steam account has been identified as MostRecent.
    echo.
    pause
)

rem Check if the most recent account is walkedgibbons
if /I !mostRecentAccount!=="walkedgibbons" (
    echo Launching Call of Duty HQ via Steam...
    start "" "steam://rungameid/1938090"
    echo Done!
    timeout /t 5 /nobreak > nul
) else (
    echo.
    echo                   Wrong Account
    echo.
    echo Please switch accounts to walkedgibbons and try again.
    echo.
    timeout /t 5 /nobreak > nul
)


REM rem Ask the user if they are logged into the proper Steam account
REM echo Are you logged into the proper Steam account? (Press Y for Yes, any other key for No)
REM
REM :input
REM set "choice="
REM rem Use PowerShell to read a single key press without requiring Enter
REM for /F "delims=" %%A in ('powershell -command "[console]::ReadKey().KeyChar.ToString()"') do set "choice=%%A"
REM
REM rem Convert choice to uppercase for case-insensitive comparison
REM set "choice=!choice:~0,1!"
REM if /I "!choice!"=="Y" (
REM     echo Launching Call of Duty HQ via Steam...
REM     start "" "steam://rungameid/1938090"
REM     echo Done!
REM     pause
REM ) else (
REM     rem If any other key was pressed, prompt the user to switch accounts
REM     echo Please switch accounts and try again.
REM     timeout /t 2 /nobreak > nul
REM     exit
REM )
