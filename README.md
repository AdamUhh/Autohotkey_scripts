# AHK scripts I actively use for Win 11

## How to use

- `Alt + E` : Open Downloads Folder
- `Ctrl + Q` : Replicate `Alt + F4` to Close Applications (Works 95% of the time)
- `Ctrl + Alt + T` : Open Terminal (cmd)
- `Middle Click` : Middle clicking on the titlebar of a window/applications sends it to the back
- `Ctrl + Shift + Alt + M` : Switch Audio Device (Will require you to edit script in order to add your own I/O device names)
- `Ctrl + Space` : Media Control, Toggles Player (Pause/Unpause)
- `Shift + Alt + ArrowLeft/ArrowRight` : Rewind/Seek Non-Focused Youtube Video by 10 seconds (Only works for Chrome, and when currently focused in an IDE)
- `Windows + ~` : Switch to another similar window/application
- `Windows + Shift + PageUp/PageDown` : Moves active window to another Windows Desktop
- `Windows + Shift + B` (Binds Window) -> `Windows + Alt + ArrowLeft/ArrowRight` : Moves binded windows/applications (can bind multiple) to another Windows Desktop
  - `Windows + Shift + Alt + B`: Lists all windows/applications
  - `Windows + Shift + Alt + U`: Unbinds all windows/applications
  - (This script sometimes bugs out, requiring users to release and hold hotkeys again to get it to move binded windows)
- `Capslock to Escape`
- `Colemak`: Converts keyboard layout to Colemak
- `Num row to symbols`: Converts your top row numbers to its symbols, kums can be activated with shift
- `Ctrl + Alt + F11`: Ensures that your window is always on top of all other windows, regardless of focus

### Note

- Please note that I added `#NoTrayIcon` to all scripts, as I am using `MonitorAHKScripts` as a master hub (to control all .ahk scripts in one place)
- Note: Unfortunately this script only shows .ahk processes and not .exe (ahk) scripts

### Irrelevant Info

Below is irrelevant as required file is included now in git folder

#### Installation

VD.AHK (<https://github.com/FuPeiJiang/VD.ahk>) is required for the below ahk scripts to work (simply put the folder 'VD.ahk' in same folder as all other scripts)

- win+shift+page_move_window_to_desktop.ahk
- ctrl+alt+arrow_move_binded_window_to_desktop.ahk
