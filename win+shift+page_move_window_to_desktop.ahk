;FROM https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys
; Source: https://github.com/phazei/Win11AutoHotKeyFixes

;#SETUP START
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon
ListLines Off
SetBatchLines -1
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#KeyHistory 0
#WinActivateForce

Process, Priority,, H

SetWinDelay -1
SetControlDelay -1

;include the library
#Include VD.ahk
; VD.init() ;COMMENT OUT `static dummyStatic1 := VD.init()` if you don't want to init at start of script

; ? Include notification library
#Include PleasantNotify.ahk

;you should WinHide invisible programs that have a window.
WinHide, % "Malwarebytes Tray Application"
;#SETUP END

VD.createUntil(3) ; create desktops until we have at least 3 VD

return

; Win + LShift + Page Up 
#<+PgUp::
    n := VD.getCurrentDesktopNum()
    if n = 1 ;at begining, can't go left
        Return

    n -= 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n), VD.goToDesktopNum(n)
    PleasantNotify("Switched Desktop", "Changed to desktop: " n , 245, 100, "vc t", "0.5")
    WinActivate active ;once in a while it's not active
Return

; Note: If you are confused why 3 desktops are being created,
; Look above -> VD.createUntil(3)

; Win + LShift + Page Down 
#<+PgDn::
    n := VD.getCurrentDesktopNum()
    if n = % VD.getCount() ;at end, can't go right
        Return

    n += 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n), VD.goToDesktopNum(n)
    PleasantNotify("Switched Desktop", "Changed to desktop: " n , 245, 100, "vc t", "0.5")
    WinActivate active
Return