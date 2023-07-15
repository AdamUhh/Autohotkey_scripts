;Source: //www.autohotkey.com/board/topic/21984-vista-audio-control-functions/?p=595799
;runs at startup:
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#NoTrayIcon

; Change this to full path to work
I_Icon_Speakers = assets/Speakers.ico
I_Icon_Headphones =  assets/Headphones.ico

Run, mmsys.cpl
WinWait,Sound
ControlSend,SysListView321,{Down} ;This is my first option in Win+R -> mmsys.cpl
ControlGet, isEnabled, Enabled,,&Set Default
ControlClick,OK
if (!isEnabled)
    IfExist, %I_Icon_Speakers%
        Menu, Tray, Icon, %I_Icon_Speakers%
else
    IfExist, %I_Icon_Headphones%
        Menu, Tray, Icon, %I_Icon_Headphones%
return

^<+!m::        ;Toggle headphones / speakers
Run, mmsys.cpl
WinWait,Sound
ControlSend,SysListView321,{Down}
ControlGet, isEnabled, Enabled,,&Set Default
if (!isEnabled)
{
    ControlSend,SysListView321,{Down 3}  ;This is my third option in Win+R -> mmsys.cpl
    IfExist, %I_Icon_Headphones%
        Menu, Tray, Icon, %I_Icon_Headphones%
}
else
    IfExist, %I_Icon_Speakers%
        Menu, Tray, Icon, %I_Icon_Speakers%
ControlClick,&Set Default
ControlClick,OK
WinWaitClose
return