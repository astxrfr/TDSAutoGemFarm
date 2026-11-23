#Requires AutoHotkey v2.0
#Include <OCR>

class Cash {
    static cashRegion := [1215, 1003, 1312, 1022]
    static currentCash := 0

    static CURRENT {
        get => Cash.currentCash
    }

    static Read() {
        try txt := OCR.FromRect(this.cashRegion[1], this.cashRegion[2], this.cashRegion[3], this.cashRegion[4], {scale: 2}).Text
        catch 
            return

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
    }
}