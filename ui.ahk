#Requires AutoHotkey v2.0

hud := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")   ; E0x20 = click-through
hud.BackColor := "353535"
hud.SetFont("bold s10 cWhite", "Inter")
hudStatus := hud.Add("Text", "w280 r1", "OFF")
hudState := hud.Add("Text", "w280 r1", "")
hudCash := hud.Add("Text", "w280 r1", "")
hud.Show("NoActivate x10 y10")                           
WinSetTransparent 200, hud

class UI {
    static UpdateStatus() {
        if running
            hudStatus.Value := "RUNNING"
        else
            hudStatus.Value := "OFF"
    }

    static SetState(msg, color := "White") {
        static last := ""
        if msg == last
            return
        last := msg
        hudState.SetFont("c" color)
        hudState.Value := msg
    }

    static SetCash(amt) {
        hudCash.Value := "Current cash: " amt
    }
}
