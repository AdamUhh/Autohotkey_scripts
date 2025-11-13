#NoEnv
#SingleInstance force
#NoTrayIcon

; Works on windows 11, havent tested for other windows
; If Explorer has multiple tabs open and Downloads isn't the active one, it brings the window up but won't jump to that tab

; Configuration
RestrictToSpecificFolders := true
ActivateExistingWindow := true  ; Set to true to activate existing window/tab, false to always open new window

; List of allowed folder names (only used when RestrictToSpecificFolders is true)
AllowedFolderNames := ["Downloads", "Documents"]

; Main hotkey - respects ActivateExistingWindow setting
!e::OpenExplorer(ActivateExistingWindow)

; Alt+Shift+E - always opens as new window
!+e::OpenExplorer(false)

OpenExplorer(shouldActivateExisting) {
    global RestrictToSpecificFolders, AllowedFolderNames
    
    EnvGet, UserProfile, USERPROFILE
    path := UserProfile . "\Downloads"
    
    ; If shouldActivateExisting is false, always open a new window
    if (!shouldActivateExisting) {
        Run, explorer.exe "%path%"
        return
    }
    
    ; Only check for existing windows when shouldActivateExisting is true
    SetTitleMatchMode, 2
    if (RestrictToSpecificFolders) {
        for index, folderName in AllowedFolderNames {
            if WinExist(folderName " ahk_class CabinetWClass") {
                WinActivate
                return
            }
        }
    } else if WinExist("ahk_class CabinetWClass") {
        WinActivate
        return
    }
    
    ; If none found, open Downloads as new tab
    Explorer_NewTab(path)
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
