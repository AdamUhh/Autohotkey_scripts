@echo off
setlocal enabledelayedexpansion
set "startup=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"

if not exist "%startup%" (
    echo ERROR: Startup folder not found.
    pause & exit /b 1
)

set /a errors=0

rem Start .ahk files and .ahk shortcuts
for %%f in ("%startup%\*.ahk" "%startup%\*.lnk") do (
    if /i "%%~xf"==".ahk" (
        start "" "%%f" 2>nul || set /a errors+=1
    ) else (
        echo %%~nf | find /i ".ahk" >nul && (
            start "" "%%f" 2>nul || set /a errors+=1
        )
    )
)

if !errors! gtr 0 echo Errors occurred starting some scripts. & pause & exit /b 1