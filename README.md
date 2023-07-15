# AHK scripts I actively use for Win 11

## Note

VD.AHK (<https://github.com/FuPeiJiang/VD.ahk>) is required for the below ahk scripts to work

- PleasantNotify.ahk
- win+shift+page_move_window_to_desktop.ahk
- ctrl+alt+arrow_move_binded_window_to_desktop.ahk

Additionally, the above scripts also need to be placed in the root of VD.AHK

### Note 2

Please note that I added `#NoTrayIcon` to all scripts, as I am (temporarily?) using `AHKScriptHub` as a master hub (to control all scripts in one place)

### AHKScriptHub References

- <https://www.the-automator.com/easily-edit-pause-reload-open-folder-for-any-running-ahk-script-works-w-o-system-tray-icon-with-ahkscripthub/>
- <https://www.youtube.com/watch?v=hdpJebygFxk>
- Also, if using AHKScriptHub, please note that you need to add a `SetProductName` and `SetDescription` if you want to compile, like the below example:
  - ;@Ahk2Exe-SetProductName AhkScriptHub
  - ;@Ahk2Exe-SetDescription A script to view and control all other scripts