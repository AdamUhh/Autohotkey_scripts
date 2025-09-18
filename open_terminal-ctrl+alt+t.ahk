#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

; Main hotkey - opens current explorer path or user profile
^!t::run_wt_from_path()

; Specific path hotkeys - customize these to your needs
; ^!p::run_wt_from_path("C:\Some_Path_Here\Projects")         ; Ctrl+Alt+P for projects

run_wt_from_path(specificPath := "") {
    path := ""                                                          ; initialize
    
  ; Priority 1: Check if active window is explorer and get its path
    if (explorerHwnd := WinActive("ahk_class CabinetWClass")) {         ; If an explorer window is active
        for window in ComObjCreate("Shell.Application").Windows             ; Iterate through windows
            if (window.hwnd = explorerHwnd)                                 ;  If explorer window matches this window
                path := window.Document.Folder.Self.Path                    ;   Save folder path
        until (path)                                                        ; Break when path is found
    }
    
    ; Priority 2: If no explorer path found, use specific path if provided
    if (!path && specificPath != "") {
        path := specificPath
    }
    
    ; Priority 3: Final fallback to user profile directory
    if !path {                                                          ; If still no path found
        EnvGet, UserProfile, USERPROFILE
        path := UserProfile
        ; Alternative defaults:
	; path := A_Desktop  ; for desktop folder
        ; path := A_MyDocuments  ; for documents folder
    }
    
    Run, wt.exe --startingDirectory `"%path%`"                          ; Run wt using path
    WinWait, ahk_exe WindowsTerminal.exe                                ; Wait for window to exist
    WinActivate                                                         ; Activate last found window
}
