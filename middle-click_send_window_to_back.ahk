; ? Source: https://www.autohotkey.com/board/topic/66686-middle-click-to-close-windows/
; ? Source: https://www.autohotkey.com/board/topic/87311-how-do-i-bring-forward-all-windows-underneath-middle-clicked-window/

;==========================================================================================================
;|||||||||||||||||||||||||||||| Middle Click to send window to back||||||||||||||||||||||||||||||||||||||||
;==========================================================================================================

#NoEnv                           ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input                     ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%           ; Ensures a consistent starting directory.
#SingleInstance force

; ================Send window to back with titlebar middle click============================
~MButton::
  SetBatchLines, -1
  CoordMode, Mouse, Screen
  SetMouseDelay, -1 ; no pause after mouse clicks
  SetKeyDelay, -1 ; no pause after keys sent
  MouseGetPos, ClickX, ClickY, WindowUnderMouseID
  WinActivate, ahk_id %WindowUnderMouseID%

  ; WM_NCHITTEST
  SendMessage, 0x84,, ( ClickY << 16 )|ClickX,, ahk_id %WindowUnderMouseID%
  WM_NCHITTEST_Result =%ErrorLevel%

; Title Bar click sends window back
  If WM_NCHITTEST_Result in 2,3,8,9,20,21 ; in titlebar enclosed area - top of window
    {
	    WinSet, Bottom, , ahk_id %WindowUnderMouseID%  ; where m contains the id of the window, probably retrieved by MouseGetPos.
    }


