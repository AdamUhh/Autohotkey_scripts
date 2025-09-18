; ──────────────────────────────────────────────────────────────
; Source: https://www.autohotkey.com/boards/viewtopic.php?t=55209
; ──────────────────────────────────────────────────────────────

help=
(
	AHK process list
• List all running AutoHotkey scripts
  - In context menu (right click):
    Close, Reload, Edit in Scite (SciTE4AHK), Run in 32bit (or in AHK_H if path provided)
	- Delete key - close running script
• List of startup AutoHotkey scripts
  - At first run, the program makes a list of all running scripts and makes an .ini file.
• Third list (Misc) of other scripts may be made manually in the .ini file or scripts may be added from running scripts with an option in the context menu
• Icons for scripts can be specified in the .ini file
• In menu:
  - Close all running scripts
  - Run all scripts from the startup scripts list
• Alt+Space - show window
• Esc - hide window
	to remove this feature - disable lines:
		~LAlt & Space:: Gui,1: Show
		Esc:: Gui,1: Hide
)

#SingleInstance force
Menu, Tray, Icon, shell32.dll, 166

Menu, Tray, NoStandard
Menu, Tray, Add, Window Spy, WindowSpy
Menu, Tray, Add
Menu, Tray, Add , Edit Scite, Edit_Scite
;Menu, Tray, Add , Edit Notepad, Edit_Notepad
Menu, Tray, Add
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , Close
Menu, Tray, Default, Exit

Menu, ScriptMenu, Add, Run all startup scripts, startAll
Menu, ScriptMenu, Icon, Run all startup scripts, Shell32.dll, 251
Menu, ScriptMenu, Add, Close all running scripts, closeAll
Menu, ScriptMenu, Icon, Close all running scripts, Shell32.dll, 153
Menu, ScriptMenu, Add,
Menu, ScriptMenu, Add, Open settings file , Open_ini
Menu, ScriptMenu, Icon, Open settings file , Shell32.dll, 70
Menu, ScriptMenu, Add,
Menu, ScriptMenu, Add, Enable monitoring, startMonitoring
Menu, ScriptMenu, Add,
Menu, ScriptMenu, Add, Restart, Reload
Menu, ScriptMenu, Add, Exit , Exit
Menu, ScriptMenu, Icon, Exit , Shell32.dll, 132
Menu, MenuBar, Add, &Menu, :ScriptMenu
Gui, Menu, MenuBar

SetBatchLines, -1

Scite4AHK_path:="C:\Program Files\AutoHotkey\SciTE\SciTE.exe"

FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%
global settings_ini := "AHK process list.ini"
global maxNum:=80
global startedScripts:=""

;======== test =============
icons_1:="C:\Program Files\AutoHotkey\AutoHotkey.exe,2" , icons_2:="shell32.dll,58", icons_3:="C:\Windows\explorer.exe"
IniRead, read_ , %settings_ini%, Startup AutoHotkey
if(!read_){
	proc_list()
	for PID in proc_list {
		FilePath:=RegExReplace(proc_list[PID][4],"i)\.ahk.*$",".ahk")
		IniWrite, %FilePath% , %settings_ini%, Startup AutoHotkey, Script%A_Index%
		ico_:=find_icon_1(FilePath)
		IniWrite, %ico_% , %settings_ini%, Startup AutoHotkey, icon%A_Index%
	}
}
IniRead, read_ , %settings_ini%, AutoHotkey
if(!read_){
	Loop 3 {
		i:=4-A_Index
		IniWrite, C:\AHK\dummy script%A_Index%.ahk , %settings_ini%, AutoHotkey, Script%A_Index%
		IniWrite, % icons_%i%, %settings_ini%, AutoHotkey, icon%A_Index%
	}
}
;======== test =============

global proc_list:= Object()
Gosub, ContextMenuMake

Gosub, show_ListView
;Gosub, startMonitoring
monitor_:=0

DllCall("RegisterShellHookWindow", "UInt",A_ScriptHwnd )
MsgNum := DllCall("RegisterWindowMessage", "Str","SHELLHOOK")
OnMessage(MsgNum,"ShellMessage")

return

;===================== scripts start, close detection ====================

;WmiPrvSE.exe
startMonitoring:
	;Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
	if(monitor_==1){
		Menu, %A_ThisMenu%, UnCheck, %A_ThisMenuItem%
		createSink.Cancel()
		deleteSink.Cancel()
		monitor_:=0
		return
	}else
		Menu, %A_ThisMenu%, Check, %A_ThisMenuItem%
	monitor_:=1
	Gosub, LVRun
	;https://autohotkey.com/board/topic/56984-new-process-notifier/#entry358038 by Lexikos
	winmgmts := ComObjGet("winmgmts:")
	; Create sink objects for receiving event noficiations.
	ComObjConnect(createSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessCreate_")
	ComObjConnect(deleteSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessDelete_")
	; Set event polling interval, in seconds.
	interval := 3

	; Register for process creation notifications:
	winmgmts.ExecNotificationQueryAsync(createSink
		, "Select * from __InstanceCreationEvent"
		. " within " interval
		. " where TargetInstance isa 'Win32_Process'")

	; Register for process deletion notifications:
	winmgmts.ExecNotificationQueryAsync(deleteSink
		, "Select * from __InstanceDeletionEvent"
		. " within " interval
		. " where TargetInstance isa 'Win32_Process'")

return

; Called when a new process is detected:
ProcessCreate_OnObjectReady(obj) {
	proc := obj.TargetInstance
	;str:="START`nID:`t" proc.ProcessID "`nName:`t" proc.Name "`nPath:`t" proc.ExecutablePath "`ncmd:`t" proc.CommandLine "`nParent:`t" proc.ParentProcessID
	;proc.Handle
	;ToolTip % str
	if(InStr(proc.Name,"AutoHotkey"))
		Gosub, makeList
}

; Called when a process terminates:
ProcessDelete_OnObjectReady(obj) {
	proc := obj.TargetInstance
	if(InStr(proc.Name,"AutoHotkey"))
		Gosub, makeList
}

;=========================================

; ? Press LAlt and Spacebar to show GUI
; ~LAlt & Space::
; 	Gosub, LVRun
; 	Gui,1: Show
; return
; Esc:: Gui,1: Hide

show_ListView:
	Gui,1: Default
	Gui,1: Margin, 0,0
	text_:=["Running scripts", "Startup scripts", "Misc"]
	Gui,1:Add, Button, x20 y3 w100 gLVRun vB1, % text_[1] ; Running scripts
	Gui,1:Add, Button, x200 y3 w100 gLVScripts vB2, % text_[2] ; Startup scripts
	Gui,1:Add, Button, x360 y3 w100 gLVMisc vB3, % text_[3] ; Misc
	Gui,1: +HWNDGuiHwnd ; +AlwaysOnTop
	Gui,1:ListView, LV_1
	; First part to changing column header names
	Gui,1: Add, ListView,x0 y30 w520 h500 vLV_1 gClickListView +HWNDList_1Hwnd, Script name|Process|Memory|PID|Full path|ID|Time started|CMD line
	LV_ModifyCol(1,280)
	LV_ModifyCol(2,140)
	LV_ModifyCol(3,90)
	LV_ModifyCol(4,50)
	LV_ModifyCol(5,300)
	LV_ModifyCol(6,60)
	LV_ModifyCol(7,100)
	LV_ModifyCol(8,740)
	LV_ModifyCol(3,"Right")
	LV_ModifyCol(4,"Center")

	Gui,1: Add, ListView,x0 y30 w520 h500 vLV_2 gClickListView +HWNDList_2Hwnd, Scripts|#
	Gui,1: Add, ListView,x0 y30 w520 h500 vLV_3 gClickListView +HWNDList_3Hwnd , Scripts|#
	GuiControl, Hide, LV_2
	GuiControl, Hide, LV_3

	Gui,1: Font, s9 w700 , Consolas
	Gui,1: Add, Text ,x140 y8 w40 c900000 vNum Center,

	/* FileGetVersion, ver, wmploc.DLL ;C:\WINDOWS\System32\wmploc.DLL
	RegExMatch(ver,"(\d+)\.\d+\.(\d+)", out) ;new 12.0.10240.16384
	new_wmploc:=(out1>=10 && out2>=8000)
	onTop_ico:=new_wmploc ? 13 : 17
	 */
	;Gui,1: Add, Picture, x490 y6 w16 h16 vonTop1  gonTop Icon%onTop_ico% AltSubmit, wmploc.dll
	Gui,1: Add, Picture, x490 y6 w16 h16 vonTop1 gonTop Icon248 AltSubmit, shell32.dll ;
	Gui,1: Add, Picture, x490 y6 w16 h16 vonTop2 gonTop Icon247 AltSubmit, shell32.dll ;
	GuiControl, Hide, onTop1
	WonTop:=0

	; ? Enable this to show GUI on startup
	;Gui,1: Show, w520 h530 , AHK process list

	IniRead, read_1, %settings_ini%, Misc, Last list
	if(read_1=="ERROR" || read_1=="")
		IniWrite, LVRun, %settings_ini%, Misc, Last list
	IniRead, last_label, %settings_ini%, Misc, Last list

	Gosub, %last_label%
	;Gosub, LVRun

	OnMessage(0x100, "WM_KEYDOWN")
	OnMessage(0x404, "AHK_NOTIFYICON")
return

WM_KEYDOWN(wParam, lParam){
	if(wParam = 13){ ; VK_ENTER := 13
	}else	if(wParam = 27){ ; Esc
	}else	if(wParam = 46){ ;  del
		row_now:=LV_GetNext(0) ;selected row number
		LV_GetText(PID,row_now , 4)
		Process, Close, %PID%
		Gosub, makeList
	}
}

AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
	if (lParam = 0x202) { ; WM_LBUTTONUP
		Gui,1:Show
	}else if (lParam = 0x203){ ; WM_LBUTTONDBLCLK
	}
}

proc_list(){
	global proc_list :=Object(), GuiHwnd
	global i_p
	WMI:=ComObjGet("winmgmts:")
	; queryEnum := WMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'AutoHotkey.exe' OR Name ='AutoHotkeyU64.exe' OR Name ='AutoHotkeyU32.exe' OR Name ='AutoHotkeyA32.exe'")._NewEnum()
	queryEnum := WMI.ExecQuery("SELECT * from Win32_Process Where Name Like 'AutoHotkey%'")._NewEnum()
	i_p:=0
	global startedScripts:=""
	DetectHiddenWindows, On
	While queryEnum[process] {
		WinGet, id, ID , % "ahk_pid " process.processId
		PID:=process.processId
		pname:=process.Name, cmd_l:=process.CommandLine, exe_l:=process.ExecutablePath

		FormatTime, process_start ,% SubStr(process.CreationDate,1,14), HH:mm ;:s
		i_p+=1

		cmd_l:=StrReplace(cmd_l, exe_l, "")
		cmd_l:=RegExReplace(cmd_l,"""","")
		full_path:=Trim(cmd_l)
		full_path:=RegExReplace(full_path,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk).*","$1")

		arr:=StrSplit(cmd_l,"\")
		cmd_l:=StrReplace(arr[arr.Length()],"""","")
		cmd_l:=RegExReplace(cmd_l,"i)\.ahk.*$",".ahk")
		cmd_l:=Trim(cmd_l)

		proc_list[process.processId]:=[pname, cmd_l,id,full_path, SubStr(process.CreationDate,1,14),process.CommandLine]

		if PID not in %startedScripts%
			startedScripts:=startedScripts "," PID
	}
	startedScripts:=RegExReplace(startedScripts,"^,|,$","")
	DetectHiddenWindows, Off
	GuiControl,, Num , % "#" i_p
	;WinSetTitle, ahk_id %GuiHwnd%, , AHK process list # %i_p%
}

find_icon(script){
	Loop, % maxNum {
		IniRead, name , %settings_ini%, Startup AutoHotkey, Script%A_Index%
		if(name=="ERROR" || name=="")
			continue
		if(name==script){
			IniRead, icon_ , %settings_ini%, Startup AutoHotkey, icon%A_Index%
			if(icon_ && icon_!="ERROR" && icon_!="")
				return icon_
		}
	}
	Loop, % maxNum {
		IniRead, name , %settings_ini%, AutoHotkey, Script%A_Index%
		if(name=="ERROR" || name=="")
			continue
		if(name==script){
			IniRead, icon_ , %settings_ini%, AutoHotkey, icon%A_Index%
			if(icon_ && icon_!="ERROR" && icon_!="")
				return icon_
		}
	}
	return null
}

makeList:
	SetTimer, makeList, Off
	Gui,1:ListView, LV_1
	LV_Delete()
	proc_list()

	ImgListID := IL_Create(i_p)
	LV_SetImageList(ImgListID)

	i:=1
	for PID in proc_list {
		icon_:=find_icon(proc_list[PID][4])
		if(!icon_){
			;IL_Add(ImgListID,"C:\Program Files\AutoHotkey\AutoHotkey.exe",2)
			IL_Add(ImgListID, A_AhkPath,2)
		}else{
			icon_arr:= StrSplit(icon_,",")
			IL_Add(ImgListID,icon_arr[1],icon_arr[2])
		}
		; Second part to changing column header names
		LV_Add("Icon" i," " proc_list[PID][2], proc_list[PID][1],GetProcessMemoryInfo(PID,"Cust"), PID,proc_list[PID][4],proc_list[PID][3],proc_list[PID][5],proc_list[PID][6])
		i++
	}

	/* ;Loop %i_p%
		;IL_Add(ImgListID,"C:\Program Files\AutoHotkey\AutoHotkey.exe",2)
		IL_Add(ImgListID,A_AhkPath,2)
	i:=1

	for PID in proc_list
		LV_Add("Icon" i ,  " " proc_list[PID][1], proc_list[PID][2],GetProcessMemoryInfo(PID,"Cust"), PID,proc_list[PID][4],proc_list[PID][3],proc_list[PID][5])
	 */
	;LV_ModifyCol(2, "SortAsc") ; by name
	LV_ModifyCol(7, "SortAsc") ; by time program started
return

LVRun:
	Gosub, ContextMenuMake
	Bt_chng(1)
	GuiControl, Show, LV_1
	GuiControl, Hide, LV_2
	GuiControl, Hide, LV_3
	Gui,1:ListView, LV_1
	Gosub, makeList
	IniWrite, %A_ThisLabel%, %settings_ini%, Misc, Last list
return

LVScripts:
	Gosub, ContextMenuMake2
	Bt_chng(2)
	GuiControl, Show, LV_2
	GuiControl, Hide, LV_1
	GuiControl, Hide, LV_3
	Gui,1:ListView, LV_2
	LV_ModifyCol(1,490)
	LV_ModifyCol(2,26)
	LV_ModifyCol(2,"Center")

	LV_Delete()
	GuiControl,, Num ,
	/* p_Height:=p_Width:=16, p_Initial:=p_Grow:=10
		ILC_MASK:=0x1, ILC_COLOR32:=0x20
		p_Flags:=ILC_MASK|ILC_COLOR32
		ImgListID_2:=DllCall("ImageList_Create","Int",p_Width,"Int",p_Height ,"UInt",p_Flags ,"Int",p_Initial ,"Int",p_Grow ,"Ptr")
	 */
	ImgListID_2 := IL_Create(maxNum)
	LV_SetImageList(ImgListID_2)

	block:="Startup AutoHotkey"
	sortINI(block)

	i:=1
	Loop, % maxNum {
		IniRead, name , %settings_ini%, %block%, Script%A_Index%
		if(name=="ERROR" || name=="")
			continue
		IniRead, icon_ , %settings_ini%, %block%, icon%A_Index%
		if(icon_=="ERROR" || icon_==""){
			;IL_Add(ImgListID_2,"C:\Program Files\AutoHotkey\AutoHotkey.exe",2)
			IL_Add(ImgListID_2, A_AhkPath,2)
		}else{
			icon_arr:= StrSplit(icon_,",")
			if(icon_arr.Length()>1){
				icon_DLL:=icon_arr[1] , icon_n:=icon_arr[2]
				IL_Add(ImgListID_2, icon_DLL, icon_n)
			}else if FileExist(icon_){
				IL_Add(ImgListID_2,icon_,1)
			}else{
				IL_Add(ImgListID_2,A_AhkPath,2)
			}

		}
		LV_Add("Icon" i, " " name,A_Index)
		i++
	}
	IniWrite, %A_ThisLabel%, %settings_ini%, Misc, Last list
return

LVMisc:
	Gosub, ContextMenuMake2
	Bt_chng(3)
	GuiControl, Show, LV_3
	GuiControl, Hide, LV_1
	GuiControl, Hide, LV_2
	Gui,1:ListView, LV_3
	LV_ModifyCol(1,490)
	LV_ModifyCol(2,26)
	LV_ModifyCol(2,"Center")
	LV_Delete()
	GuiControl,, Num ,

	ImgListID_3 := IL_Create(maxNum)
	LV_SetImageList(ImgListID_3)
	block:="AutoHotkey"
	sortINI(block)
	i:=1
	Loop, % maxNum {
		IniRead, name , %settings_ini%, %block%, Script%A_Index%
		if(name=="ERROR" || name=="")
			continue

		IniRead, icon_ , %settings_ini%, %block%, icon%A_Index%
		if(icon_=="ERROR" || icon_==""){
			;IL_Add(ImgListID_3,"C:\Program Files\AutoHotkey\AutoHotkey.exe",2)
			IL_Add(ImgListID_3, A_AhkPath,2)
		}else{
			icon_arr:= StrSplit(icon_,",")
			if(icon_arr.Length()>1){
				icon_DLL:=icon_arr[1] , icon_n:=icon_arr[2]
				IL_Add(ImgListID_3, icon_DLL, icon_n)
			}else if FileExist(icon_){
				IL_Add(ImgListID_3,icon_,1)
			}else{
				IL_Add(ImgListID_2,A_AhkPath,2)
			}
		}
		LV_Add("Icon" i, " " name,A_Index)
		i++

	}
	IniWrite, %A_ThisLabel%, %settings_ini%, Misc, Last list
return

Bt_chng(ind){
	global B1,B2,B3,text_
	;text_:=["Running scripts", "Startup scripts", "Misc"]
	Loop 3 {
		if(A_Index==ind){
			GuiControl,, B%A_Index% , % text_[A_Index] " " Chr(10004) ;✔
		}else{
			GuiControl,, B%A_Index% , % text_[A_Index]
		}
	}
}

ClickListView:
	if A_GuiEvent = DoubleClick
	{
		if(A_GuiControl=="LV_2" || A_GuiControl=="LV_3"){
			LV_GetText(FilePath,A_EventInfo , 1)
		}else{
			LV_GetText(FilePath,A_EventInfo , 5)
		}
		FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
		FilePath:=Trim(FilePath)
		if !FileExist(FilePath){
			MsgBox,,, % "File does not exist:" "`n" FilePath , 3
			return
		}
		Run, "%FilePath%"
	}
return

Run_script:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	LV_GetText(FilePath,row_now , 1)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:" "`n" FilePath , 3
		return
	}
	Run, "%FilePath%"
return

Run_script32:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	LV_GetText(FilePath,row_now , 1)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:" "`n" FilePath , 3
		return
	}
	AhkPath32:=RegExReplace(A_AhkPath,"i)AutoHotkey.exe","AutoHotkeyU32.exe")
	Run, "%AhkPath32%" "%FilePath%"
;Run, "C:\Program Files\AutoHotkey\AutoHotkeyU32.exe" "%FilePath%"
return

Run_scriptH:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	LV_GetText(FilePath,row_now , 1)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:" "`n" FilePath , 3
		return
	}
	MsgBox,,, % "Specify AutoHotkey_H path" , 3
;Run, "C:\Program Files\AutoHotkey_H\AutoHotkey.exe" "%FilePath%"
return

Close_script:
	ControlGet, vis_ , Visible,,SysListView321, ahk_id %GuiHwnd%
	if(!vis_)
		return
	LV_GetText(PID,row_now , 4)
	Process, Close, %PID%
	Gosub, makeList
return

Reload_script:
	ControlGet, vis_ , Visible,,SysListView321, ahk_id %GuiHwnd%
	if(!vis_)
		return
	LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)

	LV_GetText(PID,row_now , 4)
	WinGet, ID, ID , ahk_pid %PID%
	if(ID==GuiHwnd){
		Gosub, Reload
		return
	}
	;Process, Close, %PID%
	;Run, % FilePath
	DetectHiddenWindows On
	PostMessage 0x111, 65400,,, % "ahk_class AutoHotkey ahk_pid " . PID ;"Reload Script": 65400
	DetectHiddenWindows Off
	Sleep, 1000
	Gosub, makeList
return

Reload_script32:
	ControlGet, vis_ , Visible,,SysListView321, ahk_id %GuiHwnd%
	if(!vis_)
		return
	LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	LV_GetText(PID,row_now , 4)
	WinGet, ID, ID , ahk_pid %PID%
	if(ID==GuiHwnd){
		AhkPath32:=RegExReplace(A_AhkPath,"i)AutoHotkey.exe","AutoHotkeyU32.exe")
		Run, "%AhkPath32%" "%FilePath%"
		ExitApp
	}
	Process, Close, %PID%

	;Run, "C:\Program Files\AutoHotkey\AutoHotkeyU32.exe" "%FilePath%"
	AhkPath32:=RegExReplace(A_AhkPath,"i)AutoHotkey.exe","AutoHotkeyU32.exe")
	Run, "%AhkPath32%" "%FilePath%"
	Gosub, makeList
return

Edit_in_Scite:
	Gosub, LV_visible
	if !FileExist(Scite4AHK_path){
		MsgBox,,, % "Check path of SciTE.exe" , 3
		return
	}
	Gui,1:ListView, %ListVis% ;LV_1
	if(ListVis=="LV_2" || ListVis=="LV_3" ){
		LV_GetText(FilePath,row_now , 1)
	}else
		LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	FilePath:=RegExReplace(FilePath,"i)\.ahk.*$",".ahk")
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:" "`n" FilePath , 3
		return
	}

	Process, Exist, SciTE.exe ; not to destroy session
	PID := Errorlevel
	if !PID{
		Run , %Scite4AHK_path%
		WinWaitActive, ahk_class SciTEWindow
	}
	Run, "%Scite4AHK_path%" "%FilePath%"
return

Edit_default:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	if(ListVis=="LV_2" || ListVis=="LV_3" ){
		LV_GetText(FilePath,row_now , 1)
	}else
		LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	FilePath:=RegExReplace(FilePath,"i)\.ahk.*$",".ahk")
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:" "`n" FilePath , 3
		return
	}
	Run *Edit %FilePath%
return

LV_visible:
	Loop 3 {
		ctrl:="SysListView32" A_Index
		ControlGet, vis_ , Visible,,%ctrl%, ahk_id %GuiHwnd%
		if(vis_==1){
			ListVis:="LV_" A_Index
			break
		}else
			ListVis:=""
	}
return

startAll:
	block:="Startup AutoHotkey"
	Loop % maxNum {
		IniRead, script_ , %settings_ini%, %block%, Script%A_Index%
		if(script_=="ERROR" || script_=="")
			continue
		if InStr(script_,"AHK process list")
			continue
		Run, %script_%
		Sleep, 100
	}
return

closeAll:
	for PID in proc_list {
		WinGet, ID, ID , ahk_pid %PID%
		;WinGetTitle, title_, ahk_pid %PID%
		if(ID==GuiHwnd)
			continue
		Process, Close, %PID%
		;WinClose, ahk_pid %PID%
	}
	Gosub, makeList
return

;=========================

Copy_FileName:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	if(ListVis=="LV_2" || ListVis=="LV_3" ){
		LV_GetText(FilePath,row_now , 1)
	}else
		LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	arr:=StrSplit(FilePath,"\")
	FilePath:=StrReplace(FilePath, arr[arr.Length()], "")
	FileName:=arr[arr.Length()]
	Clipboard:=FileName
return

Copy_FilePath:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	if(ListVis=="LV_2" || ListVis=="LV_3" ){
		LV_GetText(FilePath,row_now , 1)
	}else
		LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	Clipboard:=FilePath
return

Copy_CmdLine:
	Gosub, LV_visible
	Gui,1:ListView,LV_1
	LV_GetText(CmdLine,row_now , 8)
	Clipboard:=CmdLine
return

open_folder:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis% ;LV_1
	if(ListVis=="LV_2" || ListVis=="LV_3" ){
		LV_GetText(FilePath,row_now , 1)
	}else
		LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	arr:=StrSplit(FilePath,"\")
	FolderPath:=StrReplace(FilePath, arr[arr.Length()], "")
	FilePath:=RegExReplace(arr[arr.Length()],"i)\.ahk.*$",".ahk")
	SlectFilePath:=FilePath
	Run, Explorer.exe %FolderPath%
return

;=========================

add_to_List_Start:
	LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"i)\.ahk.*$",".ahk")
	ico_:=find_icon_1(FilePath)
	block:="Startup AutoHotkey"
	Loop, % maxNum {
		ind:=A_Index ;+40
		IniRead, read_ , %settings_ini%, %block% , Script%ind%
		if(read_=="ERROR" || read_==""){
			IniWrite, %FilePath% , %settings_ini%, %block%, Script%ind%
			IniWrite, %ico_% , %settings_ini%, %block%, icon%ind%
			break
		}
	}
return

add_to_List_Misc:
	LV_GetText(FilePath,row_now , 5)
	FilePath:=RegExReplace(FilePath,"i)\.ahk.*$",".ahk")
	ico_:=find_icon_1(FilePath)
	block:="AutoHotkey"
	Loop, % maxNum {
		ind:=A_Index ;+40
		IniRead, read_ , %settings_ini%, %block% , Script%ind%
		if(read_=="ERROR" || read_==""){
			IniWrite, %FilePath% , %settings_ini%, %block%, Script%ind%
			IniWrite, %ico_% , %settings_ini%, %block%, icon%ind%
			break
		}
	}
return

find_icon_1(FilePath){
	ico_:=""
	Loop, Read, %FilePath%
	{
		if A_Index>200
			break
		pos:=RegExMatch(A_LoopReadLine,"i)(?<!;)Menu,\s*Tray,\s*Icon,\s*([^,;]+)(\s*,\s*)?([%\d]+)?", out)
		if(pos){
			icon_:= (out2 && out3) ? out1 "," out3 : out1
			if InStr(out,"`%")
				icon_:=""
			break
		}
	}
	return icon_
}

;=========================

remove_item:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis%
	block:=""

	if(ListVis=="LV_2"){
		block:=	"Startup AutoHotkey"
		SubR:="LVScripts"
	}
	if(ListVis=="LV_3"){
		block:= "AutoHotkey"
		SubR:="LVMisc"
	}
	if(block=="")
		MsgBox,4096,, % "error" "`n" , 2

	LV_GetText(FilePath,row_now , 1)

	IniRead, name_ , %settings_ini%, %block%, Script%row_now%
	;IniRead, ico_ , %settings_ini%, %block%, icon%row_now%
	MsgBox, 0x00040003, , Remove this item? `n%name_% ;+100 "No" as default
	IfMsgBox, No
		return
	IfMsgBox Cancel
		return
	Loop, % maxNum {
		IniRead, read_ , %settings_ini%, %block% , Script%A_Index%
		if(read_==name_){
			IniDelete, %settings_ini%, %block%, Script%A_Index%
			IniDelete, %settings_ini%, %block%, icon%A_Index%
			break
		}
	}

	Gosub, %SubR%
return

;=========================

move_to_row:
	Gosub, LV_visible
	Gui,1:ListView, %ListVis%
	block:=""

	if(ListVis=="LV_2"){
		block:=	"Startup AutoHotkey"
		SubR:="LVScripts"
	}
	if(ListVis=="LV_3"){
		block:= "AutoHotkey"
		SubR:="LVMisc"
	}
	if(block=="")
		MsgBox,4096,, % "error" "`n" , 2

	LV_GetText(FilePath,row_now , 1)

	IniRead, name_ , %settings_ini%, %block%, Script%row_now%
	IniRead, ico_ , %settings_ini%, %block%, icon%row_now%
	Gui,1: +OwnDialogs
	InputBox, num, %name_% , Row number,,160,120,,,,, %row_now%
	if ErrorLevel ;CANCEL
		return

	if num is not Integer
		return
	if(num<=0)
		return

	insertINI(block,name_,ico_,num)

	Gosub, %SubR%
return

insertINI(block,ins_1,ins_2,row:=1){
	obj:=Object()
	IniRead, read_ , %settings_ini%, %block%,
	Loop, % maxNum {
		IniRead, name_ , %settings_ini%, %block%, Script%A_Index%
		if(name_=="ERROR" || name_=="")
			continue
		IniRead, ico_ , %settings_ini%, %block%, icon%A_Index%
		obj[A_Index]:={name: name_,ico:ico_}
	}

	block_2:=""
	index:=1
	for i, val in obj {
		if(index=row){
			block_2:=block_2 "Script" index "=" ins_1 "`n"
			block_2:=block_2 "icon" index "=" ins_2 "`n"
			index+=1
			block_2:=block_2 "Script" index "=" obj[A_Index].name "`n"
			block_2:=block_2 "icon" index "=" obj[A_Index].ico "`n"

		}else if(obj[A_Index].name==ins_1){
			continue
		}else{
			block_2:=block_2 "Script" index "=" obj[A_Index].name "`n"
			block_2:=block_2 "icon" index "=" obj[A_Index].ico "`n"
		}
		index+=1
	}
	if(row>=obj.Length()){
		block_2:=block_2 "Script" obj.Length() "=" ins_1 "`n"
		block_2:=block_2 "icon" obj.Length() "=" ins_2 "`n"
	}

	;MsgBox,4096,, % block_2
	IniWrite, %block_2% , %settings_ini%, %block%
}

sortINI(block){
	obj:=Object()
	IniRead, read_ , %settings_ini%, %block%,

	Loop, % maxNum {
		IniRead, name_ , %settings_ini%, %block%, Script%A_Index%
		if(name_=="ERROR" || name_=="")
			continue
		IniRead, ico_ , %settings_ini%, %block%, icon%A_Index%
		obj[A_Index]:={name: name_,ico:ico_}
	}

	block_2:=""
	for index, val in obj {
		block_2:=block_2 "Script" A_Index "=" obj[index].name "`n"
		block_2:=block_2 "icon" A_Index "=" obj[index].ico "`n"
	}
	;MsgBox,4096,, % block_2
	IniWrite, %block_2% , %settings_ini%, %block%
}

;=========================

ContextMenuMake:
	Menu, ContextMenu, Add
	Menu, ContextMenu, DeleteAll
	Menu, ContextMenu, Add , Edit , Edit_default
	Menu, ContextMenu, Icon, Edit , Shell32.dll, 71
	Menu, ContextMenu, Add , Edit in Scite , Edit_in_Scite
	if FileExist(Scite4AHK_path)
		Menu, ContextMenu, Icon , Edit in Scite , %Scite4AHK_path%

	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add , Reload script , Reload_script
	Menu, ContextMenu, Icon , Reload script ,Shell32.dll, 239
	Menu, ContextMenu, Add , Close script , Close_script
	Menu, ContextMenu, Icon, Close script , Shell32.dll, 272
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add , Run script 32bit , Reload_script32
	Menu, ContextMenu, Icon, Run script 32bit, %A_AhkPath%
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add , Add to Start list , add_to_List_Start
	Menu, ContextMenu, Icon, Add to Start list, shell32.dll,280
	Menu, ContextMenu, Add , Add to Misc list , add_to_List_Misc
	Menu, ContextMenu, Icon, Add to Misc list, shell32.dll,280
	Menu, ContextMenu, Add,

	Menu, More, Add
	Menu, More, DeleteAll
	Menu, More, Add, Open in folder, open_folder
	Menu, More, Icon, Open in folder, shell32.dll,5
	Menu, More, Add,
	Menu, More, Add, Copy file name, Copy_FileName
	Menu, More, Add, Copy file path, Copy_FilePath
	Menu, More, Add
	Menu, More, Add, Copy command line, Copy_CmdLine
	Menu, ContextMenu, Add, More, :More

;Menu, ContextMenu, Add,
;Menu, ContextMenu, Add, Restart, Reload
;Menu, ContextMenu, Add, Exit , Exit
;Menu, ContextMenu, Icon, Exit , Shell32.dll, 132
return

ContextMenuMake2:
	Menu, ContextMenu, Add
	Menu, ContextMenu, DeleteAll
	Menu, ContextMenu, Add , Run script , Run_script
	Menu, ContextMenu, Icon, Run script , Shell32.dll, 3
	Menu, ContextMenu, Add , Edit , Edit_default
	Menu, ContextMenu, Icon, Edit , Shell32.dll, 71
	Menu, ContextMenu, Add , Edit in Scite , Edit_in_Scite
	if FileExist(Scite4AHK_path)
		Menu, ContextMenu, Icon , Edit in Scite ,%Scite4AHK_path%
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add , Run script 32bit , Run_script32
	Menu, ContextMenu, Icon, Run script 32bit, %A_AhkPath%
	;Menu, ContextMenu, Add , Run script in AHK_H , Run_scriptH
	;Menu, ContextMenu, Add , Run script in AHK_v2 , Run_scriptH

	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Move to row #..., move_to_row
	Menu, ContextMenu, Icon, Move to row #..., Shell32.dll,124 ;imageres.dll, 161
	Menu, ContextMenu, Add, Remove item, remove_item
	Menu, ContextMenu, Icon, Remove item, Shell32.dll, 153
	Menu, ContextMenu, Add,

	Menu, More, Add, Open in folder, open_folder
	Menu, More, Icon, Open in folder, shell32.dll,5
	Menu, More, Add, Copy file name, Copy_FileName
	Menu, More, Add, Copy file path, Copy_FilePath
	Menu, ContextMenu, Add, More, :More

;Menu, ContextMenu, Add,
;Menu, ContextMenu, Add, Restart, Reload
return

GuiContextMenu:
	if !InStr(A_GuiControl,"LV_")
		return
	menu_control_now:=A_GuiControl
	row_now:=A_EventInfo
	Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
return

;===================================

ShellMessage(wParam,lParam){
	if(wParam=1){ ;  HSHELL_WINDOWCREATED = 1  ; new program started
		;WinGet, pname, ProcessName,ahk_id %lParam%
		WinGetClass, class_, ahk_id %lParam%
		id:=Format("0x{1:x}", lParam) ; decimal to hexadecimal
		if(RegExMatch(class_,"i)CabinetWClass")){
			fn:=Func("selectInWindow").Bind(id)
			SetTimer, %fn% , -500
		}
	}

	if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
	}
}

selectInWindow(hwnd){
	global SlectFilePath
	FileName:=SlectFilePath
	SlectFilePath:=""
	win := GetShellFolder(hwnd)
	fold_path:=win.Document.Folder.Self.Path
	win.Document.SelectItem(win.Document.Folder.ParseName(FileName), 1|4|8)
}

GetShellFolder(Win_id){
	for win in ComObjCreate("Shell.Application").Windows {
		if(win.hwnd == Win_id)
			return win
	}
}

;===================================

GetProcessMemoryInfo(PID,Units:="M"){
	size := (A_PtrSize=8 ? 80 : 44)
	VarSetCapacity(mem,size,0)
	memory := 0
	hProcess := DllCall("OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr)
	if (hProcess){
		if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &mem, UInt,size))
			memory := Round(NumGet(mem, (A_PtrSize=8 ? 16 : 12), "Ptr"))
		DllCall("CloseHandle", Ptr, hProcess)

		if(Units == "raw"){
			return % memory
		}else	if(Units == "Cust"){
			memory := Round(memory/1024)
			if(memory<40000){
				RegExMatch(memory,"(\d+)(\d{3})$", out)
				memory:=out1 "," out2
				return % memory " KB"
			}else{
				memory := Round(memory/1024)
				return % memory " MB"
			}
		}else	if(Units == "B"){
			memory := memory " B"
		}else if(Units == "K"){
			memory := Round(memory/1024) " KB"
		}else if(Units == "M"){
			memory := Round(memory / 1024 / 1024)	 " MB"
		}
		return % memory
	}
}

;===================================

Edit_Notepad:
;Run, "C:\Program Files\Misc\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
	if !FileExist(Scite4AHK_path)
		return
	Process, Exist, SciTE.exe ; not to destroy session
	PID := Errorlevel
	if !PID{
		Run , %Scite4AHK_path%
		WinWaitActive, ahk_class SciTEWindow
	}
	Run, "%Scite4AHK_path%" "%A_ScriptFullPath%"
return

Open_ini:
	Run, %settings_ini%
return

onTop:
	if(WonTop=0){
		WinSet, AlwaysOnTop, On, % "ahk_id " GuiHwnd
		GuiControl, Hide , onTop2
		GuiControl, Show , onTop1
		WonTop:=1
	}else{
		WinSet, AlwaysOnTop, Off, % "ahk_id " GuiHwnd
		GuiControl, Hide , onTop1
		GuiControl, Show , onTop2
		WonTop:=0
	}
return

Reload:
Reload
return

WindowSpy:
	Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk" ;"C:\Program Files\AutoHotkey\AU3_Spy.exe"
;WinWait, ahk_exe AU3_Spy.exe , , 3
;WinMove, Active Window Info, , 1100
return

GuiClose:
GuiEscape:
Close:
	Gui, Hide
Return
Exit:
ExitApp
Return

