#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
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

F8:: {
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
    if FindImage(&x, &y, Image.Button.READY, skipAreaRegion) {
        ToolTip "READY at [" x "," y "] - starting session"
        ClickAt(x, y)
        Sleep(100)
    }

    if FindStableImage(&x, &y, Image.Button.SKIP, skipAreaRegion) {
        ClickAt(x, y)
        Sleep(10)
        ResetCursorPos()
    }

    if !WalkUntilLandmark(Image.Landscape.SPOT_1)
        ToolTip "Didn't reach the landmark, resetting"
}

ResetCursorPos() {
    MouseMove(A_ScreenWidth//4*3, A_ScreenHeight//2, 10)
}

ClickAt(x, y) {
    MouseMove x, y, 8
    Sleep 10
    Click "down"
    Sleep 20
    Click "up"
}

PlaceTower(x, y, slot) {

}

FindImage(&x, &y, image, region) {
    global detectionTolerance

    try found := ImageSearch(&fx, &fy, region[1], region[2], region[3], region[4], "*" detectionTolerance " " image)
    catch as e {
        ToolTip "ImageSearch error: " e.Message
        return false
    }

    if !found
        return false

    x := fx
    y := fy
    CenterImgSearchCoords(image, &x, &y)
    return true
}

; Waits until the image is found AND hasn't moved for stableMs.
; Returns the final (stable) position in x,y.
FindStableImage(&x, &y, image, region, timeoutMs := 5000, stableMs := 300, maxDrift := 2) {
    start := A_TickCount
    lastX := "", lastY := "", stableSince := 0

    while A_TickCount - start < timeoutMs {
        if FindImage(&cx, &cy, image, region) {
            if lastX != "" && Abs(cx - lastX) <= maxDrift && Abs(cy - lastY) <= maxDrift {
                if A_TickCount - stableSince >= stableMs {
                    x := cx, y := cy
                    return true
                }
            } else {
                stableSince := A_TickCount    ; first sighting or it moved: restart the clock
            }
            lastX := cx, lastY := cy
        } else {
            lastX := ""                       ; lost it, start over
        }
        Sleep 50
    }
    return false
}

WalkUntilLandmark(landmark, timeoutMs := 4000, tol := 40, area := fullScreenRegion) {
    start := A_TickCount
    Send "{s down}"
    try {
        while A_TickCount - start < timeoutMs {
            try found := ImageSearch(&fx, &fy, area[1], area[2], area[3], area[4], "*" tol " " landmark)
            catch as e {
                ToolTip "ImageSearch error: " e.Message
                break
            }
            if found
                return true
            Sleep 30
        }
    } finally {
        Send "{s up}"      ; never leave S stuck down, even on an error
    }
    return false
}

CenterImgSearchCoords(img, &x, &y) {
    GetImageSize(img, &w, &h)

    x += w // 2
    y += h // 2
}

GetImageSize(img, &w, &h) {
    g := Gui("-DPIScale")
    pic := g.Add("Picture", , img)
    pic.GetPos(, , &w, &h)
    g.Destroy()
}