#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

; Main hotkey - opens Downloads folder dynamically
!e::open_explorer_path()

; Specific folder hotkeys
; !p::open_explorer_path("C:\Some_Path_Here\Projects")         ; Alt+P for projects

open_explorer_path(specificPath := "") {
    path := ""                                                          ; initialize
    
    ; Priority 1: Use specific path if provided
    if (specificPath != "") {
        path := specificPath
    }
    else {
        ; Priority 2: Default to user's Downloads folder
        EnvGet, UserProfile, USERPROFILE
        path := UserProfile . "\Downloads"
        ; Alternative defaults:
        ; path := UserProfile . "\Documents"  ; for Documents folder
        ; path := UserProfile . "\Desktop"    ; for Desktop folder
    }
    
    Run, explorer.exe "%path%"                                          ; Open explorer at path
}
