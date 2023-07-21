; Source: https://www.autohotkey.com/boards/viewtopic.php?f=5&t=4832&p=28778#p27904

; FROM https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys
; Source2: https://github.com/phazei/Win11AutoHotKeyFixes

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
#Include %A_ScriptDir%\VD.ahk\VD.ahk
; VD.init() ;COMMENT OUT `static dummyStatic1 := VD.init()` if you don't want to init at start of script

; ? Include notification library
#Include %A_ScriptDir%\NotificationGUIs\Notify.ahk

;you should WinHide invisible programs that have a window.
WinHide, % "Malwarebytes Tray Application"
;#SETUP END

VD.createUntil(3) ; create desktops until we have at least 3 VD

/*	Init()
 *	Runs when the script is first loaded. If the WindowPositions.txt file exists it will load all of the stored window positions into MyWindowArray.
 *	Creates MyWindowArray. Used to initialize WriteFile(), StorWindows(), and RestoreWindowPos().
 * 	All functions share the same object.
 */
Init() {
    static MyWindowArray
    if (!IsObject(MyWindowArray)) {
        MyWindowArray := {}
    }
    return MyWindowArray
}

MoveLeft() {
    static MyWindowArray := Init()
    n := VD.getCurrentDesktopNum()
    if n = 1 ;at begining, can't go left
        Return

    WinGet, Win, List
    Loop, % Win {

        winId := "ahk_id" Win%A_Index%

        ; if there is an object in MyWindowArray with a key matching the window title
        ; move the window to the position stored by that object
        if (IsObject(MyWindowArray[winId])) {
            if (!moved)
                n -= 1
            VD.MoveWindowToDesktopNum(MyWindowArray[winId].ID,n), VD.goToDesktopNum(n)
            moved := true
        }
    }
    if (!moved) and (MyWindowArray.Count() > 0) {
        UnbindAllWindows()
    }

    WinActivate active ;once in a while it's not active

    if (moved)
        Notify("Switched Desktop (Bind)","Changed to desktop: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

}

MoveRight() {
    static MyWindowArray := Init()
    moved := false
    n := VD.getCurrentDesktopNum()
    if n = % VD.getCount() ;at end, can't go right
        Return

    WinGet, Win, List
    Loop, % Win {

        winId := "ahk_id" Win%A_Index%

        ; if there is an object in MyWindowArray with a key matching the window title
        ; move the window to the position stored by that object
        if (IsObject(MyWindowArray[winId])) {
            if (!moved)
                n += 1
            VD.MoveWindowToDesktopNum(MyWindowArray[winId].ID,n), VD.goToDesktopNum(n)
            moved := true
        }
    }

    if (!moved) and (MyWindowArray.Count() > 0) {
        UnbindAllWindows(true)
    }

    WinActivate active

    if (moved)
        Notify("Switched Desktop (Bind)","Changed to desktop: " n, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

}

ToggleWindowBind() {
    static MyWindowArray := Init()

    WinGetTitle, title, A ;Active window title
    active := "ahk_id" WinExist("A")

    if (IsObject(MyWindowArray[active])) {
        MyWindowArray[active] := ""
        Notify("Unbinded Window", title, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

        return
    }
    else {
        MyWindowArray[active] := {ID: active, TITLE: title}
        Notify("Binded Window", title, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

        return
    }
}

ListBindedWindows() {
    static MyWindowArray := Init()
    Value_Array := []
    for Key, Val in MyWindowArray
        if (Val)
            Value_Array.Push(MyWindowArray[Key].TITLE)

    if (Value_Array.Length() = 0) {
        MsgBox, % "No Binded Windows"
        return
    } else
        for Key, Val in Value_Array
            List .= Key "`t" Val "`n"
    MsgBox, % List

    return
}

UnbindAllWindows(deletedWindow = false) {
    static MyWindowArray := Init()
    isUnbinded := false
    for Key, Val in MyWindowArray
        if (Val) {
            ; Below Delete are not required anymore since the below Remove is doing the work
            ; Source: https://www.autohotkey.com/board/topic/90734-method-to-delete-object/
            ; MyWindowArray[Key] := ""
            ; MyWindowArray.Delete(Key)
            isUnbinded := true ; Keep this to signify that there was Keys beforehand
        }
    MyWindowArray.Remove("", Chr(255))
    MyWindowArray.SetCapacity(0)
    if (isUnbinded) {
        if (deletedWindow) {
            Notify("Could not find any windows", "Unbinding all windows", 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

        } else {
            Notify("Unbinded All Windows",, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

        }
    }
    else
        Notify("Nothing to Unbind",, 0.5, "GC=F0F8FF TC=194499 MC=194499 GR=0 BR=0 TF=Segoe UI MF=Segoe UI TS=10 MS=10 TW=625 MW=625 IW=38 IH=38 Image=" 222)

    return
}

return

; Note: If you are confused why 3 desktops are being created,
; Look above -> VD.createUntil(3)

; Ctrl + Alt + Arrow Left
^!Left::MoveLeft()

; Ctrl + Alt + Arrow Right
^!Right::MoveRight()

; Ctrl + Alt + B
^!B::ToggleWindowBind()

; Ctrl + Alt + LShift + B
^!<+B::ListBindedWindows()

; Ctrl + Alt + LShift + U
^!<+U::UnbindAllWindows()

