; ──────────────────────────────────────────────────────────────
; Source: https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys
; Source: https://github.com/phazei/Win11AutoHotKeyFixes
; ──────────────────────────────────────────────────────────────

; ──────────────────────────────────────────────────────────────
; INITIALIZATION AND SETUP
; ──────────────────────────────────────────────────────────────

; Performance and compatibility settings
#NoEnv                          ; Recommended for performance and compatibility
#SingleInstance force           ; Replace existing instance if running
#NoTrayIcon                     ; Hide tray icon
ListLines, Off                  ; Disable line logging for performance
SetBatchLines, -1              ; Run at maximum speed
SendMode, Input                ; Use Input mode for superior speed
SetWorkingDir, %A_ScriptDir%   ; Set consistent working directory
#KeyHistory, 0                 ; Disable key history
#WinActivateForce              ; Force window activation
Process, Priority,, H          ; Set high process priority
SetWinDelay, -1               ; No delay after windowing commands
SetControlDelay, -1           ; No delay after control commands

; ──────────────────────────────────────────────────────────────
; LIBRARY INCLUDES
; ──────────────────────────────────────────────────────────────

; Virtual Desktop library
#Include %A_ScriptDir%\VD.ahk\VD.ahk

; Notification GUI library
#Include %A_ScriptDir%\NotificationGUIs\Notify.ahk

; ──────────────────────────────────────────────────────────────
; STARTUP CONFIGURATION
; ──────────────────────────────────────────────────────────────

; Hide background applications
WinHide, % "Malwarebytes Tray Application"

; Initialize virtual desktops (minimum of 3)
VD.createUntil(3)


; ──────────────────────────────────────────────────────────────
; NOTIFICATION STYLE
; ──────────────────────────────────────────────────────────────
notifyStyle := "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=222"

return


; ──────────────────────────────────────────────────────────────
; MOVE WINDOW HELPER FUNCTION
; ──────────────────────────────────────────────────────────────
MoveWindow(direction) {
    global notifyStyle

    n := VD.getCurrentDesktopNum()
    max := VD.getCount()
    active := "ahk_id" WinExist("A")

    if (direction = "left") {
        if (n = 1) {
            Notify("Can't go left anymore", "Max Desktop Reached: " n, 0.5, notifyStyle)
            Return
        }
        n -= 1
    } else if (direction = "right") {
        if (n = max) {
            Notify("Can't go right anymore", "Max Desktop Reached: " n, 0.5, notifyStyle)
            Return
        }
        n += 1
    }

    VD.MoveWindowToDesktopNum(active, n)
    VD.goToDesktopNum(n)
    Notify("Switched Desktop", "Changed to desktop: " n, 0.5, notifyStyle)
    WinActivate active
}

; ──────────────────────────────────────────────────────────────
; HOTKEYS
; ──────────────────────────────────────────────────────────────
#<+PgUp::MoveWindow("left")
#<+PgDn::MoveWindow("right")
