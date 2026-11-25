#Requires AutoHotkey v2.0
#Include tower.ahk

class Operator extends Tower {
    baseCost := 300
    upgradeCosts := [
        325,
        700,
        1250,
        1950,
        3500,
        7000
    ]
}