#Requires AutoHotkey v2.0
#Include sequence.ahk

class Inputs {    
    static ResetCursorPos() {
        return Sequence.Builder()
            .AddWait(10)
            .AddNext(() => MouseMove(A_ScreenWidth//4*3, A_ScreenHeight//2, 10))
            .Build()
    }

    static ClickAt(x, y) {
        return Sequence.Builder()
            .AddNext(() => MouseMove(x, y, 8))
            .AddWait(10)
            .AddNext(() => Click("down"))
            .AddWait(20)
            .AddNext(() => Click("up"))
            .Build()
    }

    static PlaceTower(x, y, slot) {
        slotSelect := Sequence.Builder()
            .AddNext(() => Send("{" slot " down}"))
            .AddWait(10)
            .AddNext(() => Send("{" slot " up}"))
            .AddWait(10)
            .Build()

        clickAt := Inputs.ClickAt(x, y)
        delay := Sequence.Builder().AddWait(1000).Build()
        return slotSelect.Add(clickAt).Add(delay)
    }

    static UpgradeImmediately() {
        return Sequence.Builder()
            .AddNext(() => Send("{e down}"))
            .AddWait(10)
            .AddNext(() => Send("{e up}"))
            .AddWait(20)
            .AddWait(1000)
            .Build()
    }
}
