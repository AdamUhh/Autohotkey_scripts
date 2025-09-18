; ──────────────────────────────────────────────────────────────
; Switch between open Windows of the same App (.exe)
; Similar to Command+` on Linux/Mac
;
; Source: https://github.com/phazei/Win11AutoHotKeyFixes
; ──────────────────────────────────────────────────────────────

; ──────────────────────────────────────────────────────────────
; INITIALIZATION AND SETUP
; ──────────────────────────────────────────────────────────────

; Performance and compatibility settings
#NoEnv                          ; Recommended for performance and compatibility
#SingleInstance force           ; Replace existing instance if running
#NoTrayIcon                     ; Hide tray icon
ListLines Off                   ; Disable line logging for performance
SetBatchLines -1               ; Run at maximum speed
SendMode Input                 ; Use Input mode for superior speed
SetWorkingDir %A_ScriptDir%    ; Set consistent working directory
#KeyHistory 0                  ; Disable key history
#WinActivateForce             ; Force window activation

; Process and delay settings
Process, Priority,, H          ; Set high process priority
SetWinDelay -1                ; No delay after windowing commands
SetControlDelay -1            ; No delay after control commands

; Display settings
CoordMode, ToolTip, Screen     ; Set tooltip coordinate mode

; Window detection settings
DetectHiddenWindows, off       ; Don't show hidden windows from other desktops

return

; ──────────────────────────────────────────────────────────────
; HOTKEY DEFINITIONS
; ──────────────────────────────────────────────────────────────
; Note: Using Sc029 (grave accent/backtick) for Win11 compatibility
; Reference: https://www.autohotkey.com/boards/viewtopic.php?t=23009
; ──────────────────────────────────────────────────────────────

!Sc029::
    SwitchToSameProcess()
return

+!Sc029::
    SwitchToSameProcess(true)
return

; ──────────────────────────────────────────────────────────────
; MAIN WINDOW SWITCHING FUNCTION
; ──────────────────────────────────────────────────────────────
SwitchToSameProcess(reverse := "") {
    global prevArray
    global lastIndex

    ; Get current active window information
    activeId := WinExist("A")
    ahk_idId := "ahk_id " activeID
    WinGet, ActiveProcess, ProcessName, %ahk_idId%
    ahk_exeProcess := "ahk_exe" ActiveProcess
    activeArray := GetProcessWindowsArray(ahk_exeProcess)

    ; Debug tooltips (uncomment if needed)
    ;ToolTip % MakeListString(activeArray), 100, 250, 3
    ;ToolTip % MakeListString(prevArray), 100, 375, 4

    ; Check if there are multiple windows to switch between
    if (activeArray.Length() = 1) {
        prevArray := ""             ; Clear working arrays
        return                      ; Nothing to switch to
    }

    ; Handle window stack order changes
    ; This enables consistent forward/backward movement while accounting for
    ; user clicking windows out of order
    currentIndex := GetArrayIndex(prevArray, activeId)
    
    if (ArrayMatch(prevArray, activeArray)) {
        ; Same windows, check if focus changed unexpectedly
        if (lastIndex AND currentIndex != lastIndex) {
            ; Stack order changed - update arrays
            prevArray := activeArray
        }
    } else {
        ; Different windows involved - must update
        prevArray := activeArray
    }
    
    currentIndex := GetArrayIndex(prevArray, activeId)
    
    if (!lastIndex)
        lastIndex = currentIndex

    activeArray := prevArray        ; Maintain consistent order for cycling

    ; Calculate next window index
    currentIndex := GetArrayIndex(activeArray, activeId)
    
    if (!reverse) {
        ; Forward: go to next window
        nextIndex := currentIndex + 1
        if (nextIndex > activeArray.Length()) {
            nextIndex = 1
        }
    } else {
        ; Backward: go to previous window
        nextIndex := currentIndex - 1
        if (nextIndex < 1) {
            nextIndex := activeArray.Length()
        }
    }

    ; Debug tooltips (if needed)
    ;ToolTip % "nextIndex:" nextIndex , 100, 100, 1
    ;ToolTip % MakeListString(activeArray), 100, 120, 2

    ; Switch to selected window
    lastIndex := nextIndex
    WinActivate, % "ahk_id " activeArray[nextIndex]
}


; ──────────────────────────────────────────────────────────────
; WINDOW ENUMERATION
; ──────────────────────────────────────────────────────────────
GetProcessWindowsArray(search) {
    ; Return list of windows as array object for easier handling
    windowArray := []

    WinGet, listOfWindows, List, %search%, , , "PopupHost"
    
    Loop %listOfWindows% {
        hwnd := listOfWindows%A_Index%
        WinGet, minimized, MinMax, % "ahk_id" hwnd

        ; Optional: Uncomment to exclude minimized windows
        ;if (minimized < 0)
        ;    continue

        windowArray.Push(hwnd)
    }

    return windowArray
}

; ──────────────────────────────────────────────────────────────
; ARRAY COMPARISON UTILITIES
; ──────────────────────────────────────────────────────────────

; Check if arrays contain same elements in sequence (allowing rotation)
; Example: [1,2,3,4] == [3,4,1,2] but [1,2,3,4] != [2,1,3,4]
ArrayMatchSequence(arr1, arr2) {
    ; First verify arrays have same elements
    if (!ArrayMatch(arr1, arr2))
        return false

    ; Find where first element of arr1 appears in arr2
    shiftedIndex := GetArrayIndex(arr2, arr1[1]) - 1

    ; Check if sequence matches with rotation
    Loop % arr1.Length() {
        index2 := A_Index + shiftedIndex
        if (index2 > arr1.Length())
            index2 := index2 - arr1.Length()

        if (arr1[A_Index] != arr2[index2])
            return false
    }
    return true
}

; Check if arrays contain the same elements (order independent)
ArrayMatch(arr1, arr2) {
    arr1String := ArrayToSortedString(arr1)
    arr2String := ArrayToSortedString(arr2)
    return arr1String = arr2String
}

; Convert array to sorted string for comparison
ArrayToSortedString(arr) {
    arrString := ""
    Loop % arr.Length() {
        arrString := arrString "," arr[A_Index]
    }
    Trim(arrString, ",")
    Sort arrString, D,
    return arrString
}

; Find index of item in array
GetArrayIndex(arr, item) {
    index := ""
    Loop % arr.Length() {
        if (arr[A_Index] = item) {
            index := A_Index
            break
        }
    }
    return index
}


; ──────────────────────────────────────────────────────────────
; WINDOW LIST FORMATTER (FOR DEBUGGING)
; ──────────────────────────────────────────────────────────────
; MakeListString(winArray) {
;     foundProcessesArr := []
;
;     ; Gather window information
;     Loop % winArray.Length() {
;         hwnd := winArray[A_Index]
;         ahk_idId := "ahk_id " hwnd
;
;         ; Get window properties
;         WinGet, exe, ProcessName, %ahk_idId%
;         WinGetTitle, wTitle, %ahk_idId%
;         WinGetClass, wClass, %ahk_idId%
;
;         foundProcessesArr.Push({
;             num: A_Index, 
;             id: hwnd, 
;             exe: exe, 
;             wClass: wClass, 
;             wTitle: wTitle, 
;             desktopNum_: desktopNum_
;         })
;     }
;
;     ; Format output string
;     finalStr := "('0' for ""Show on all desktops"", '1' for Desktop 1)`n`n"
;
;     for unused, v_ in foundProcessesArr {
;         finalStr .= v_.desktopNum_ " | #:" v_.num " | id:" v_.id 
;                  . " | e:" v_.exe " | c:" v_.wClass " | t:" v_.wTitle "`n"
;     }
;
;     return finalStr
; }
