#Requires AutoHotkey v2.0
#Include main.ahk

class Character {
    static Reset() {
        seq := Sequence.Builder()
            .AddNext(() => Send("{Escape down}"))
            .AddWait(10)
            .AddNext(() => Send("{Escape up}"))
            .AddWait(20)
            .AddNext(() => Send("{r down}"))
            .AddWait(10)
            .AddNext(() => Send("{r up}"))
            .AddWait(20)
            .AddNext(() => Send("{Enter down}"))
            .AddWait(10)
            .AddNext(() => Send("{Enter up}"))
            .Build()

        INPUT_SCHEDULER.Queue(seq)
    }

    /**
     * @deprecated
     */
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
        return Sequence.Builder()
            .AddNext(() => Send("{s down}"))
            .AddWait(timeMs)
            .AddNext(() => Send("{s up}"))
            .Build()
    }
}
