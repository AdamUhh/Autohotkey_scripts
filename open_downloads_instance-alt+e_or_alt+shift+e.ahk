#NoEnv
#SingleInstance force
#NoTrayIcon

ActivateExistingWindow := true  ; true = activate existing, false = always new

!e::OpenExplorer(ActivateExistingWindow)
!+e::OpenExplorer(false)

OpenExplorer(shouldActivateExisting) {
    EnvGet, UserProfile, USERPROFILE
    path := UserProfile . "\Downloads"

    if (!shouldActivateExisting) {
        ; Open a new window
        Run, explorer.exe "%path%"
        return
    }

    ; Try to find an existing explorer window with the path
    hwnd := FindExplorerWithPath(path)
    if hwnd {
        RestoreAndActivate(hwnd)
        SwitchToTabWithPath(hwnd, path)
        return
    }

    ; Fallback: any "Downloads" window
    SetTitleMatchMode, 2
    if WinExist("Downloads ahk_class CabinetWClass") {
        RestoreAndActivate("A")
        return
    }

    ; If none found, open Downloads as new tab
    Explorer_NewTab(path)
}

RestoreAndActivate(hwnd) {
    ; If window is minimized, restore it first
    WinGet, MinMax, MinMax, ahk_id %hwnd%
    if (MinMax = -1)
        WinRestore, ahk_id %hwnd%

    ; Use COM to get the shell window and navigate to same path
    for window in ComObjCreate("Shell.Application").Windows {
        if (window.HWND != hwnd)
            continue
        try {
            path := window.Document.Folder.Self.Path
            window.Navigate2(path)  ; forces Explorer to refresh/focus tab
        }
    }

    ; Finally, activate normally
    WinActivate, ahk_id %hwnd%
}

FindExplorerWithPath(targetPath) {
    targetPath := RTrim(targetPath, "\")
    for window in ComObjCreate("Shell.Application").Windows {
        if InStr(window.FullName, "explorer.exe") {
            try windowPath := window.Document.Folder.Self.Path
            windowPath := RTrim(windowPath, "\")
            if (windowPath = targetPath)
                return window.HWND
        }
    }
    return 0
}

SwitchToTabWithPath(parentHwnd, targetPath) {
    targetPath := RTrim(targetPath, "\")
    tabNumber := 0

    for window in ComObjCreate("Shell.Application").Windows {
        if (window.HWND != parentHwnd)
            continue
        try {
            tabNumber++
            if (RTrim(window.Document.Folder.Self.Path, "\") = targetPath) {
                Send, ^%tabNumber%
                return
            }
        }
    }
}

; Source (author: ntepa): https://www.autohotkey.com/boards/viewtopic.php?t=123320
Explorer_NewTab(path) {
    ExplorerHwnd := WinExist("ahk_class CabinetWClass")
    
    if (!ExplorerHwnd) {
        Run, explorer.exe "%path%"
        return
    }
    
    ; Get current count of Explorer windows
    Windows := ComObjCreate("Shell.Application").Windows
    Count := Windows.Count
    
    ; Restore if minimized
    WinGet, MinMax, MinMax, ahk_id %ExplorerHwnd%
    if (MinMax = -1)
        WinRestore, ahk_id %ExplorerHwnd%
    
    ; Open new tab
    PostMessage, 0x0111, 0xA21B, 0, , ahk_id %ExplorerHwnd%
    
    ; Wait for new tab (max 5 seconds)
    timeout := A_TickCount + 5000
    while (Windows.Count = Count && A_TickCount < timeout)
        Sleep, 10
    
    ; If new tab created, navigate to path
    if (Windows.Count > Count) {
        try {
            Item := Windows.Item(Count)
            Item.Navigate2(path)
        } catch {
            Run, explorer.exe "%path%"
        }
    } else {
        ; If failed, open new window
        Run, explorer.exe "%path%"
    }
}
