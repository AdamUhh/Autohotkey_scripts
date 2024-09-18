;FROM https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys
; Source: https://github.com/phazei/Win11AutoHotKeyFixes

;#SETUP START
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon
ListLines, Off
SetBatchLines, -1 ; Use SetBatchLines -1 to never sleep (i.e. have the script run at maximum speed). The default setting is 10m
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.
#KeyHistory, 0
#WinActivateForce

Process, Priority,, H

SetWinDelay, -1 ; Sets the delay that will occur after each windowing command, such as WinActivate.
SetControlDelay, -1 ; A short delay (sleep) is done automatically after every Control command that changes a control, namely Control, ControlMove, ControlClick, ControlFocus, and ControlSetText (ControlSend uses SetKeyDelay).

;include the library
#Include %A_ScriptDir%\VD.ahk\VD.ahk
; VD.init() ;COMMENT OUT `static dummyStatic1 := VD.init()` if you don't want to init at start of script

; ? Include notification library
#Include %A_ScriptDir%\NotificationGUIs\Notify.ahk

;you should WinHide invisible programs that have a window.
WinHide, % "Malwarebytes Tray Application"
;#SETUP END

VD.createUntil(3) ; create desktops until we have at least 3 VD

return

; Win + LShift + Page Up
#<+PgUp::
    n := VD.getCurrentDesktopNum()
    if (n = 1) { ;at beginning, can't go left
        Notify("Can't go left anymore", "Max Desktop Reached: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)
        Return
    }

    n -= 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n), VD.goToDesktopNum(n)
    Notify("Switched Desktop","Changed to desktop: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)
    WinActivate active ;once in a while it's not active
Return

; Note: If you are confused why 3 desktops are being created,
; Look above -> VD.createUntil(3)

; Win + LShift + Page Down
#<+PgDn::
    n := VD.getCurrentDesktopNum()
    if (n = VD.getCount()) { ;at end, can't go right
        Notify("Can't go right anymore", "Max Desktop Reached: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)
        Return
    }

    n += 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n), VD.goToDesktopNum(n)
    Notify("Switched Desktop","Changed to desktop: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

    WinActivate active
Return