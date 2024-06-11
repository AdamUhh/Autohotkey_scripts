#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

#IfWinActive, ahk_exe code.exe
    CapsLock::Escape
#If ; This closes the IfWinActive condition, only needed if more code is after