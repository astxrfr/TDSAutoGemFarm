#Requires AutoHotkey v2.0
#Include sequence.ahk

class Inputs {    
    static ResetCursorPos() {
        return Sequence.Builder()
            .AddNext(() => MouseMove(A_ScreenWidth//4*3, A_ScreenHeight//2, 10))
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

        click := Inputs.ClickAt(x, y)
        return slotSelect.Add(click)
    }
}
