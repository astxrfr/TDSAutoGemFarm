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
restartRegion               := [973, 857, 1240, 916]
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
        SetTimer TickWatchdog, 50
        SetTimer INSCHE_TICK, 10
        UI.UpdateStatus()
    } else {
        SetTimer Tick, 0
        SetTimer TickCash, 0
        SetTimer TickSkipper, 0
        SetTimer TickWatchdog, 0
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
    static pending := 0
    static armed := true

    if pending is Sequence {
        if !pending.done
            return

        pending := 0
    }

    found := Image.Search.FindStableImage(&x, &y, Image.Button.SKIP, promptRegion)

    if !found {
        armed := true
        return
    }

    if !armed
        return

    pending := Inputs.ClickAt(x, y).AndReset()
    armed := false
    INPUT_SCHEDULER.Queue(pending)
}

TickCash() {
    Cash.Read()
    UI.SetCash(Cash.CURRENT)
}

TickWatchdog() {
    global currentState

    if currentState = State.RESTART
        return

    if MatchEnded(&x, &y)
        Restart(x, y)
}

StateExecute(current) {
    switch current {
        case State.SETUP: return Setup()
        case State.READY: return ReadyUp()
        case State.PLACING: return Placing()
        case State.END: return End() 
        case State.RESTART: return State.RESTART

        default: return current
    }
}

Setup() {
    static setupPending := 0
    UI.SetState("Current state: " StrUpper(State.SETUP))

    if !(setupPending is Sequence) {
        setupPending := Character.Walk(2000)
        INPUT_SCHEDULER.Queue(setupPending)
    }
    
    if !setupPending.done {
        return State.SETUP
    }

    setupPending := 0
    return State.READY
}

ReadyUp() {
    static readyPending := 0

    UI.SetState("Current state: " StrUpper(State.READY))

    if readyPending is Sequence {
        if !readyPending.done
            return State.READY

        readyPending := 0
        return State.PLACING
    }

    if !Image.Search.FindImage(&x, &y, Image.Button.READY, promptRegion) {
        return State.READY
    }

    readyPending := Inputs.ClickAt(x, y).AndReset()
    readyPending.Add(Sequence.Builder()
            .AddWait(80)
            .Build()
    )
    INPUT_SCHEDULER.Queue(readyPending)
    return State.READY
}

Placing() {
    UI.SetState("Current state: " StrUpper(State.PLACING))

    if Placement.Manager.AttemptNext() = -1
        return State.END

    return State.PLACING
}

End() {
    UI.SetState("Current state: " StrUpper(State.END))
    return State.END
}

Restart(x, y) {
    global currentState
    static restartPending := 0
    currentState := State.RESTART
    UI.SetState("Current state: " StrUpper(State.RESTART))

    if restartPending is Sequence {
        if !restartPending.done
            return

        restartPending := 0
        currentState := State.SETUP
    }

    if !ran {
        Placement.Manager.Reset()
        INPUT_SCHEDULER.Reset()
        INPUT_SCHEDULER.Queue()
        INPUT_SCHEDULER.Queue(Character.Reset())
        ran := true
    }
}

MatchEnded(&x, &y) {
    return Image.Search.FindImage(&x, &y, Image.Button.RESTART, restartRegion)
}
