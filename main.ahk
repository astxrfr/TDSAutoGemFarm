#Requires AutoHotkey v2.0
#SingleInstance Force
#Include image.ahk
#Include state.ahk
#Include character.ahk
#Include inputs.ahk
#Include ui.ahk
#Include cash.ahk
#Include inputScheduler.ahk
#Include placement.ahk

CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
SendMode "Event"

if !A_IsAdmin {
    try Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; ---------- CONFIG ----------
pyroSlot                    := 1
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
        SetTimer TickSkipper, 50
        SetTimer INSCHE_TICK, 10
        UI.UpdateStatus()
    } else {
        SetTimer Tick, 0
        SetTimer TickCash, 0
        SetTimer TickSkipper, 0
        SetTimer INSCHE_TICK, 0
        UI.UpdateStatus()
    }
}

F12::ExitApp

Tick() { 
    global currentState
    currentState := StateExecute(currentState)
}

TickSkipper() {
    if Image.Search.FindStableImage(&x, &y, Image.Button.SKIP, promptRegion) {
        clickAt := Inputs.ClickAt(x, y).AndReset()
        
        INPUT_SCHEDULER.Queue(clickAt)
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
        case State.PLACING: return Placing()
        case State.RESTART: return Restart() 

        default: return current
    }
}

Setup() {
    static pending := 0
    UI.SetState("Current state: " StrUpper(State.SETUP))

    if !(pending is Sequence) {
        pending := Character.Walk(2000)
        INPUT_SCHEDULER.Queue(pending)
    }
    
    if !pending.done {
        return State.SETUP
    }

    pending := 0
    return State.READY
}

ReadyUp() {
    static pending := 0

    UI.SetState("Current state: " StrUpper(State.READY))

    if pending is Sequence {
        if !pending.done
            return State.READY

        pending := 0
        return State.PLACING
    }

    if !Image.Search.FindImage(&x, &y, Image.Button.READY, promptRegion) {
        return State.READY
    }

    pending := Inputs.ClickAt(x, y).AndReset()
    pending.Add(Sequence.Builder()
            .AddWait(80)
            .Build()
    )
    INPUT_SCHEDULER.Queue(pending)
    return State.READY
}

Placing() {
    UI.SetState("Current state: " StrUpper(State.PLACING))

    if Placement.Manager.AttemptNext() = -1
        return State.RESTART

    return State.PLACING
}

Restart() {
    UI.SetState("Current state: " StrUpper(State.RESTART))
}
