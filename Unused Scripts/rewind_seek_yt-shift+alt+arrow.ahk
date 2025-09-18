; Source: https://superuser.com/questions/1531362/control-the-video-behavior-in-another-window-using-the-keyboard
;============================== Start Auto-Execution Section ==============================
#NoTrayIcon
; Keeps script permanently running
#Persistent

; Avoids checking empty variables to see if they are environment variables
; Recommended for performance and compatibility with future AutoHotkey releases
#NoEnv

; Ensures that there is only a single instance of this script running
#SingleInstance, Force

;Determines whether invisible windows are "seen" by the script
DetectHiddenWindows, On

; Makes a script unconditionally use its own folder as its working directory
; Ensures a consistent starting directory
SetWorkingDir %A_ScriptDir%

; sets title matching to search for "containing" isntead of "exact"
SetTitleMatchMode, 2

;sets controlID to 0 every time the script is reloaded
controlID       := 0

return



;============================== Main Script ==============================
#IfWinNotActive, ahk_exe chrome.exe

+!Left::
   SeekYoutube("left") 
   return

+!Right::
   SeekYoutube("right") 
   return

return

SeekYoutube(arrowKey) {
    ; Gets the control ID of google chrome
    ControlGet, controlID, Hwnd,,Chrome_RenderWidgetHostHWND1, Google Chrome

    ; Focuses on chrome without breaking focus on what you're doing
    ControlFocus,,ahk_id %controlID%

    ; Checks to make sure YouTube isn't the first tab before starting the loop
    ; Saves time when youtube is the tab it's on
    IfWinExist, YouTube
    {
        If (arrowKey = "left") 
            ControlSend, Chrome_RenderWidgetHostHWND1, j , Google Chrome
        Else 
            ControlSend, Chrome_RenderWidgetHostHWND1, l , Google Chrome
        return
    }

    ; Sends ctrl+1 to your browser to set it at tab 1
    ControlSend, , ^1, Google Chrome

    ; Starts loop to find youtube tab
    Loop
    {
        IfWinExist, YouTube
        {
            break
        }

        ;Scrolls through the tabs.
        ControlSend, ,{Control Down}{Tab}{Control Up}, Google Chrome

        ; if the script acts weird and is getting confused, raise this number
        ; Sleep, is measures in milliseconds. 1000 ms = 1 sec
        Sleep, 250
    }

    Sleep, 50

    If (arrowKey = "left")
        ControlSend, Chrome_RenderWidgetHostHWND1, j , Google Chrome
    Else
        ControlSend, Chrome_RenderWidgetHostHWND1, l , Google Chrome

    return
}
return

#IfWinNotActive


;============================== End Script ==============================

