#Persistent
; Configuration constants
global startX := 390
global endX := 2050
global startY := 110
global endY := 1000
global yIncrement := 4
global mouseSpeed := 1

; State variables
global isRunning := false
global currentY := startY
global currentState := 1

; Toggle script on/off with Alt+S
!s::
{
    isRunning := !isRunning
    if (isRunning) {
        SetTimer, DragPattern, 20
    } else {
        SetTimer, DragPattern, Off
    }
    return
}

; Main drag pattern routine
DragPattern:
{
    ; Stop if reached bottom of screen
    if (currentY >= endY) {
        isRunning := false
        SetTimer, DragPattern, Off
        return
    }
    
    ; Alternate between horizontal drag directions
    if (currentState = 1) {
        MouseClickDrag, Left, startX, currentY, endX, currentY, mouseSpeed
        currentState := 2
    } else if (currentState = 2) {
        currentY += yIncrement
        currentState := 3
    } else if (currentState = 3) {
        MouseClickDrag, Left, endX, currentY, startX, currentY, mouseSpeed
        currentState := 4
    } else if (currentState = 4) {
        currentY += yIncrement
        currentState := 1
    }
    return
}

; Exit script
Esc::ExitApp
