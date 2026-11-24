#Requires AutoHotkey v2.0
#Include ..\procedure.ahk
#Include ..\inputs.ahk
#Include ..\cash.ahk

class Tower {
    baseCost := 0
    upgradeCosts := []
    slot := 0

    __New(x, y, level) {
        if level < 0
            level := 0
        if level > this.upgradeCosts.Length
            level := this.upgradeCosts.Length

        this.x := x
        this.y := y
        this.level := level
    }

    GetProcedure() {
        proc := Procedure.Builder()
            .AddCondition(this.Place())

        loop this.level 
            proc.AddCondition(this.UpgradeImmediately(A_Index))

        return proc.Build()
    }

    Place() {
        return Condition(
            () => Cash.CURRENT >= this.baseCost,
            Inputs.PlaceTower(this.x, this.y, this.slot),
            this.baseCost
        )
    }

    UpgradeImmediately(level) {
        return Condition(
            () => Cash.CURRENT >= this.upgradeCosts[level],
            Inputs.UpgradeImmediately(),
            this.upgradeCosts[level]
        )
    }
}