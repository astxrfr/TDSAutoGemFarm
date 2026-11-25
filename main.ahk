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

detectionTolerance          := 60       ; 0-255
restartPos                  := [1107, 891]
promptRegion                := [775, 133, 1147, 245]
restartRegion               := [963, 853, 1259, 928]
fullScreenRegion            := [0, 0, A_ScreenWidth, A_ScreenHeight]
; ----------------------------

running := false
currentState := State.SETUP

SESSION := {
    generation: 0,
    setupPending: 0,
    readyPending: 0,
    skipPending: 0,
    skipArmed: true,
    restartPending: 0,
    restartPhase: 0,
    restartRetryAt: 0
}

INPUT_SCHEDULER := InputScheduler()
MACRO_TIMEOUT_MS := 8 * 60 * 1000  ; 8 minutes
startedAt := A_TickCount

F8::{
    global running
    running := !running

    if running {
        SetTimer Tick, 50
        SetTimer TickCash, 25
        SetTimer TickSkipper, 50
        SetTimer TickWatchdog, 50
        SetTimer InputTick, 10
        UI.UpdateStatus()
    } else {
        SetTimer Tick, 0
        SetTimer TickCash, 0
        SetTimer TickSkipper, 0
        SetTimer TickWatchdog, 0
        SetTimer InputTick, 0
        UI.UpdateStatus()
    }
}

F12::ExitApp

Tick() {
    global currentState

    Critical "On"
    try {
        if !running
            return

        currentState := StateExecute(currentState)
    } finally {
        Critical "Off"
    }
}

InputTick() {
    Critical "On"
    try {
        if running
            INPUT_SCHEDULER.Tick()
    } finally {
        Critical "Off"
    }
}

TickSkipper() {
    if !running || currentState = State.RESTART
        return

    generation := SESSION.generation

    if SESSION.skipPending is Sequence {
        if !SESSION.skipPending.done
            return

        SESSION.skipPending := 0
    }

    found := FindSkip(&x, &y)

    Critical "On"
    try {
        if !running || currentState = State.RESTART
            return
        if generation != SESSION.generation
            return

        if !found {
            SESSION.skipArmed := true
            return
        }

        if !SESSION.skipArmed
            return

        SESSION.skipPending := Inputs.ClickAt(x, y).AndReset()
        SESSION.skipArmed := false
        INPUT_SCHEDULER.Queue(SESSION.skipPending)
    } finally {
        Critical "Off"
    }
}

TickCash() {
    Cash.Read()
    UI.SetCash(Cash.CURRENT)
}

TickWatchdog() {
    if !running || currentState = State.RESTART
        return

    generation := SESSION.generation

    if !MatchEnded()
        return

    Critical "On"
    try {
        if !running
            return
        if generation != SESSION.generation
            return
        if currentState = State.RESTART
            return

        BeginRestart(restartPos[1], restartPos[2])
    } finally {
        Critical "Off"
    }
}

StateExecute(current) {
    switch current {
        case State.SETUP: return Setup()
        case State.READY: return ReadyUp()
        case State.PLACING: return Placing()
        case State.END: return End() 
        case State.RESTART: return RestartTick()

        default: return current
    }
}

Setup() {
    UI.SetState("Current state: " StrUpper(State.SETUP))

    if !(SESSION.setupPending is Sequence) {
        SESSION.setupPending := Character.Walk(2000)
        INPUT_SCHEDULER.Queue(SESSION.setupPending)
    }

    if !SESSION.setupPending.done
        return State.SETUP

    SESSION.setupPending := 0
    return State.READY
}

ReadyUp() {
    UI.SetState("Current state: " StrUpper(State.READY))

    if SESSION.readyPending is Sequence {
        if !SESSION.readyPending.done
            return State.READY

        SESSION.readyPending := 0
        return State.PLACING
    }

    if !Image.Search.FindImage(
        &x, &y, Image.Button.READY, promptRegion
    )
        return State.READY

    SESSION.readyPending := Inputs.ClickAt(x, y).AndReset()
    SESSION.readyPending.Add(
        Sequence.Builder()
            .AddWait(80)
            .Build()
    )

    INPUT_SCHEDULER.Queue(SESSION.readyPending)
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

BeginRestart(x, y) {
    global currentState
    SESSION.restartRetryAt := A_TickCount + 2000

    currentState := State.RESTART
    SESSION.generation++

    INPUT_SCHEDULER.Reset()

    SESSION.setupPending := 0
    SESSION.readyPending := 0
    SESSION.skipPending := 0
    SESSION.skipArmed := true
    SESSION.restartPending := 0
    SESSION.restartPhase := 0

    Placement.Manager.Reset()

    SESSION.restartPending := Inputs.ClickAt(x, y).AndReset()
    INPUT_SCHEDULER.Queue(SESSION.restartPending)
}

RestartTick() {
    global startedAt

    UI.SetState("Current state: " StrUpper(State.RESTART))

    if !SESSION.restartPending.done
        return State.RESTART

    if SESSION.restartPhase = 0 {
        if !NewMatchReady() {
            if A_TickCount >= SESSION.restartRetryAt {
                SESSION.restartPending :=
                    Inputs.ClickAt(restartPos[1], restartPos[2]).AndReset()

                INPUT_SCHEDULER.Queue(SESSION.restartPending)
                SESSION.restartRetryAt := A_TickCount + 2000
            }

            return State.RESTART
        }

        SESSION.restartPending := Character.Reset()

        SESSION.restartPhase := 1
        INPUT_SCHEDULER.Queue(SESSION.restartPending)
        return State.RESTART
    }

    SESSION.restartPending := 0
    SESSION.restartPhase := 0
    startedAt := A_TickCount
    return State.SETUP
}

NewMatchReady() {
    return Image.Search.FindImage(&x, &y, Image.Button.READY, promptRegion)
}

MatchEnded() {
    return Image.Search.FindImage(&x, &y, Image.Button.RESTART, restartRegion)
        OR Image.Search.FindImage(&x, &y, Image.Button.RESTART_2, restartRegion)
        OR Image.Search.FindImage(&x, &y, Image.Landscape.YOU_LOST, fullScreenRegion)
        OR Timeout()
}

Timeout() {
    global startedAt, MACRO_TIMEOUT_MS

    return A_TickCount - startedAt >= MACRO_TIMEOUT_MS
}

FindSkip(&x, &y) {
    return Image.Search.FindStableImage(&x, &y, Image.Button.SKIP, promptRegion) OR Image.Search.FindStableImage(&x, &y, Image.Button.SKIP_2, promptRegion)
}
