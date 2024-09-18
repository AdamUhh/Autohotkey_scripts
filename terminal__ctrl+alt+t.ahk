#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

; ^!t:: run, cmd.exe, C:\Users\Adam
; ^!t:: Run, PowerShell.exe, C:\Users\Adam

^!t::run_wt_from_path()

run_wt_from_path() {
    path := ""                                                          ; intialize

    if !(explorerHwnd := WinActive("ahk_class CabinetWClass"))          ; If not an explorer window
        path := "C:\Users\Adam"                                                          ;  Go no further
    
    for window in ComObjCreate("Shell.Application").Windows             ; Iterate through windows
        if (window.hwnd = explorerHwnd)                                 ;  If explorer window matches this window
            path := window.Document.Folder.Self.Path                    ;   Save folder path
    until (path)                                                        ; Break when path is found
    
    if !path                                                            ; If no path
        path := "C:\Users\Adam"                                               ;  Default to desktop
    
    Run, wt.exe --startingDirectory `"%path%`"           ; Run wt using path
    WinWait, ahk_exe WindowsTerminal.exe                                ; Wait for window to exist
    WinActivate                                                         ; Activate last found window
}
