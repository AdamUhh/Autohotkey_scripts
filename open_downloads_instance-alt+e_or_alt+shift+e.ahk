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
        Run, explorer.exe "%path%"
        return
    }
    
    ; Try to find existing window with path
    if (hwnd := FindExplorerWithPath(path)) {
        RestoreAndActivate(hwnd)
        SwitchToTabWithPath(hwnd, path)
        return
    }
    
    ; Fallback: any "Downloads" window
    SetTitleMatchMode, 2
    if WinExist("Downloads ahk_class CabinetWClass") {
        RestoreAndActivate(WinExist())
        return
    }
    
    ; Open in new tab or window
    Explorer_NewTab(path)
}

RestoreAndActivate(hwnd) {
    ; Restore if minimized
    WinGet, MinMax, MinMax, ahk_id %hwnd%
    if (MinMax = -1)
        WinRestore, ahk_id %hwnd%
    
    ; Refresh/focus tab via COM
    for window in ComObjCreate("Shell.Application").Windows {
        if (window.HWND = hwnd) {
            try window.Navigate2(window.Document.Folder.Self.Path)
            break
        }
    }
    
    WinActivate, ahk_id %hwnd%
}

FindExplorerWithPath(targetPath) {
    targetPath := RTrim(targetPath, "\")
    
    for window in ComObjCreate("Shell.Application").Windows {
        if InStr(window.FullName, "explorer.exe") {
            try {
                if (RTrim(window.Document.Folder.Self.Path, "\") = targetPath)
                    return window.HWND
            }
        }
    }
    return 0
}


SwitchToTabWithPath(parentHwnd, targetPath) {
    targetPath := RTrim(targetPath, "\")
    tabNumber := 0
    
    for window in ComObjCreate("Shell.Application").Windows {
        if (window.HWND = parentHwnd) {
            try {
                tabNumber++
                if (RTrim(window.Document.Folder.Self.Path, "\") = targetPath) {
                    Send, ^%tabNumber%
                    return
                }
            }
        }
    }
}


; Source (author: ntepa): https://www.autohotkey.com/boards/viewtopic.php?t=123320
Explorer_NewTab(path) {
    if (!(ExplorerHwnd := WinExist("ahk_class CabinetWClass"))) {
        Run, explorer.exe "%path%"
        return
    }
    
    ; Get current count
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
    
    ; Navigate to path if new tab created
    if (Windows.Count > Count) {
        try {
            Windows.Item(Count).Navigate2(path)
        } catch {
            Run, explorer.exe "%path%"
        }
    } else {
        Run, explorer.exe "%path%"
    }
}
