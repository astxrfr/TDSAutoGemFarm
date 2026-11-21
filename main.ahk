#Requires AutoHotkey v2.0
#SingleInstance Force
#Include image.ahk
#Include state.ahk
#Include character.ahk
#Include output.ahk

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
skipAreaRegion              := [775, 133, 1147, 245]
fullScreenRegion            := [0, 0, A_ScreenWidth, A_ScreenHeight]
; ----------------------------

running := false
currentState := State.SETUP

F8::{
    global running
    running := !running

    if running {
        SetTimer Tick, 100
        ToolTip "Macro ON (F8 to stop)"
    } else {
        SetTimer Tick, 0
        ToolTip "Macro OFF"
        SetTimer () => ToolTip(), -1500
    }
}

F12::ExitApp

Tick() {
    global currentState 
    currentState := StateExecute(currentState)

    if Image.FindStableImage(&x, &y, Image.Button.SKIP, skipAreaRegion) {
        ClickAt(x, y)
        Sleep(10)
        ResetCursorPos()
    }
}

StateExecute(state) {
    switch state {
        case State.SETUP: return Setup()
        case State.RELOCATE: return ReadyUp()

        default: return state
    }
}

Setup() {
    if !WalkUntilLandmark(Image.Landscape.SPOT_1)
        Reset()
        return State.SETUP

    return State.READY
}

ReadyUp() {
    if Image.FindImage(&x, &y, Image.Button.READY, skipAreaRegion) {
        ToolTip "READY at [" x "," y "] - starting session"
        ClickAt(x, y)
        Sleep(100)
    }

    return State.PLACEMENT
}
