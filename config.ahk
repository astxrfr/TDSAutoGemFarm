#Requires AutoHotkey v2.0
#Include towers\GPyromancer.ahk
#Include towers\GSoldier.ahk
#Include towers\Operator.ahk

class Config {
    /**
     * Contains the configuration for the slots used by the macro.
     */
    class Slots {
        ; You can edit the towers each slot uses here. Don't change any parameters.
        static ONE(x, y, lvl) {
            return GoldenPyromancer(x, y, lvl, 1)
        }
        static TWO(x, y, lvl) {
            return Operator(x, y, lvl, 2)
        }
    }
}