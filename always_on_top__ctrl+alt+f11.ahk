; Source: https://www.autohotkey.com/board/topic/94627-button-for-always-on-top/?p=596509
; Source v2: https://stackoverflow.com/a/77654040

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

^!F11::
  WinGetActiveTitle, t
    WinGet, ExStyle, ExStyle, %t%
    if (ExStyle & 0x8)
    {
      WinSet, AlwaysOnTop, Off, %t%
      WinSetTitle, %t%,, % RegexReplace(t, " - AlwaysOnTop")
    }
    else
    {
      WinSet, AlwaysOnTop, On, %t%
      WinSetTitle, %t%,, %t% - AlwaysOnTop
    }
  return
