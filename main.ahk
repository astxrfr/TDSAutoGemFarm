#Requires AutoHotkey v2.0
#SingleInstance Force
#Include image.ahk
#Include state.ahk
#Include character.ahk
#Include input.ahk
#Include ui.ahk
#Include cash.ahk
#Include inputScheduler.ahk

CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
SendMode "Event"

if !A_IsAdmin {
    try Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; ---------- CONFIG ----------
flamethrowerSlot            := 1
soldierSlot                 := 2

detectionTolerance          := 40       ; 0-255
promptRegion                := [775, 133, 1147, 245]
fullScreenRegion            := [0, 0, A_ScreenWidth, A_ScreenHeight]
; ----------------------------

running := false
currentState := State.SETUP

INPUT_SCHEDULER := InputScheduler()
INSCHE_TICK := ObjBindMethod(INPUT_SCHEDULER, "Tick")

F8::{
    global running
    running := !running

    if running {
        SetTimer Tick, 50
        SetTimer TickCash, 50
        SetTimer INSCHE_TICK, 10
        UI.UpdateStatus()
    } else {
        SetTimer Tick, 0
        SetTimer TickCash, 0
        SetTimer INSCHE_TICK, 0
        UI.UpdateStatus()
    }
}

F12::ExitApp

Tick() { 
    global currentState
    currentState := StateExecute(currentState)

    if Image.Search.FindStableImage(&x, &y, Image.Button.SKIP, promptRegion) {
        Inputs.ClickAt(x, y)
        Sleep(10)
        Inputs.ResetCursorPos()
    }
}

TickCash() {
    Cash.Read()
    UI.SetCash(Cash.CURRENT)
}

StateExecute(current) {
    switch current {
        case State.SETUP: return Setup()
        case State.READY: return ReadyUp()
        case State.PLACEMENT: return Placement() 

        default: return current
    }
}

Setup() {
    UI.SetState("Current state: " StrUpper(State.SETUP))

    if !Character.Walk(2000) {
        return State.SETUP
    }

    return State.READY
}

ReadyUp() {
    UI.SetState("Current state: " StrUpper(State.READY))

    if Image.Search.FindImage(&x, &y, Image.Button.READY, promptRegion) {
        ToolTip "READY at [" x "," y "] - starting session"
        Inputs.ClickAt(x, y)
        Sleep(10)
        Inputs.ResetCursorPos()
        Sleep(80)
    }

    return State.PLACEMENT
}

Placement() {
    UI.SetState("Current state: " StrUpper(State.PLACEMENT))


}
