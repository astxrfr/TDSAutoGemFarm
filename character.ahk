#Requires AutoHotkey v2.0
#Include main.ahk

class Character {
    static Reset() {
        Send "{Escape down}"
        Sleep 10
        Send "{Escape up}"
        Sleep 20
        Send "{r down}"
        Sleep 10
        Send "{r up}"
        Sleep 20
        Send "{Enter down}"
        Sleep 10
        Send "{Enter up}"
    }

    static WalkUntilLandmark(landmark, timeoutMs := 4000, tol := 40, area := fullScreenRegion) {
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

    static Walk(timeMs) {
        start := A_TickCount
        Send "{s down}"
        Sleep timeMs
        Send "{s up}"
        
        return true
    }
}
