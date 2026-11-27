#Requires AutoHotkey v2.0
#Include tower.ahk

/**
 * ============================================================
 * You can define new towers here
 * following the template:
 * 
 * class {TowerName} extends Tower {
 *      baseCost := {tower's cost}
 *      upgradeCosts := [{lvl1}, {lvl2}, ..., {lvlmax}]
 * }
 * ============================================================
 */

class GoldenPyromancer extends Tower {
    baseCost := 850
    upgradeCosts := [
        325,
        900,
        2777,
        7500,
        16000
    ]
}

class GoldenSoldier extends Tower {
    baseCost := 450
    upgradeCosts := [
        150,
        800,
        3400,
        11350
    ]
}

class Electroshocker extends Tower {
    baseCost := 650
    upgradeCosts := [
        275,
        950,
        2400,
        4000,
        10000
    ]
}

class MilitaryBase extends Tower {
    baseCost := 1400
    upgradeCosts := [
        750,
        1100,
        3500,
        15000,
        37500
    ]
}

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

class Kingpin extends Tower {
    baseCost := 3600
    upgradeCosts := [
        1400,
        4000,
        6000
    ]
}