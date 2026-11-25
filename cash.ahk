#Requires AutoHotkey v2.0
#Include <OCR>

class Cash {
    static cashPos := [1224, 1008]
    static cashH := 16
    static cashW := 50
    static currentCash := 0
    static valid := false

    static CURRENT {
        get => Cash.currentCash
    }

    static CanAfford(cost) {
        return this.valid && this.currentCash >= cost
    }

    static Read() {
        this.valid := false
        try txt := OCR.FromRect(this.cashPos[1], this.cashPos[2], this.cashW, this.cashH, {scale: 2}).Text
        catch 
            return

        UI.SetReadCash(txt)
        txt := RegExReplace(txt, "[Oo]", "0")          ; lookalikes, safe in a digits-only crop
        txt := RegExReplace(txt, "[lI|]", "1")
        if !RegExMatch(txt, "(\d[\d,.]*)\s*([KkMm])?", &m)
            return

        try n := Number(StrReplace(m[1], ",", ""))
        catch
            return
        
        if m[2] != ""
            n *= (StrUpper(m[2]) = "K") ? 1000 : 1000000
        
        Cash.currentCash := Round(n)
        this.valid := true
    }
}