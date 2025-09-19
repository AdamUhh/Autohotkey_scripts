# AHK Scripts for Windows 11  

A collection of AutoHotkey scripts I actively use on Windows 11, plus some archived/unused ones that might still be useful.  

---

## Active Scripts  

| Hotkey | Action |
|--------|---------|
| `Alt + E` | Open Downloads folder |
| `Ctrl + Alt + T` | Open Terminal (PowerShell) |
| `Ctrl + Shift + Alt + M` | Switch audio device *(requires editing script with your own I/O device names)* |
| `Alt + ~` | Switch to another similar window/application |
| `Win + Shift + PageUp/PageDown` | Move active window to another Windows Desktop |

*Note: To switch audio devices, first edit the script and check the DEBUG comment for setup instructions.*

---

## Archived Scripts  

| Hotkey | Action |
|--------|---------|
| `Ctrl + Q` | Close applications (acts like `Alt + F4`, works ~95% of the time :P) |
| `Middle Click (on title bar)` | Send window/application to the back |
| `Ctrl + Space` | Media control (toggle pause/unpause) |
| `Shift + Alt + ArrowLeft/Right` | Seek YouTube video by 10s (only works in Chrome + IDE focus) |
| `Win + Shift + B` | Bind windows/apps for moving between desktops |
| `Win + Alt + ArrowLeft/Right` | Move bound windows/apps between desktops |
| `Win + Shift + Alt + B` | List all bound windows/apps |
| `Win + Shift + Alt + U` | Unbind all windows/apps |
| `CapsLock` | Remapped to `Escape` |
| `Colemak` | Keyboard remapped to Colemak layout |
| `Symbols` | Number row remapped to symbols (numbers via `Shift`) |
| `Ctrl + Alt + F11` | Force window to always stay on top |

*Note: The bind window script may bug out, so you may need to release and hold the hotkeys again)*  

---

## Notes  

- Most scripts include `#NoTrayIcon`, since I use `MonitorAHKScripts.ahk` as a master hub to manage them.  
- The monitor script only detects `.ahk` scripts, not compiled `.exe` versions.  

---

## VD Installation  

Some scripts require [VD.AHK](https://github.com/FuPeiJiang/VD.ahk).  
Simply place the `VD.ahk` folder in the same directory as the scripts below:  

- `move_win_desktop-win+shift+pg.ahk`  
- `move_binded_window_to_desktop-ctrl+alt+arrow.ahk`  

