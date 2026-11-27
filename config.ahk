#Requires AutoHotkey v2.0
#Include towers\towers.ahk
#Include strats\strats.ahk

class Config {
    ; Set to true if you have VIP and autoskip is enabled
    static AUTO_SKIP := true
    
    /**
     * Contains the configuration for the slots used by the macro.
     */
    class Slots {
        ; You can edit the towers each slot uses here. Don't change any parameters.
        static ONE(x, y, lvl) {
            return GoldenPyromancer(x, y, lvl, 1)
        }
        static TWO(x, y, lvl) {
            return Kingpin(x, y, lvl, 2)
        }
    }

    /**
     * Contains the strat used by the macro.
     */
    static STRAT {
        get => TowerEXPFarmStrat
    }
}