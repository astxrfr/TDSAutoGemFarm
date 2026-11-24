#Requires AutoHotkey v2.0
#Include towers\GPyromancer.ahk
#Include towers\GSoldier.ahk

class Placement {
    static CURRENT := 1
    static ORDER := [
            GoldenPyromancer(847, 475, 2),
            GoldenSoldier(748, 648, 2),
            GoldenSoldier(848, 666, 2),
            GoldenSoldier(771, 568, 2),
            GoldenSoldier(867, 573, 2),
            GoldenSoldier(951, 679, 2),
            GoldenPyromancer(1165, 576, 2),
            GoldenSoldier(944, 593, 2),
            GoldenSoldier(1085, 698, 2),
            GoldenSoldier(745, 716, 2),
            GoldenSoldier(854, 747, 2),
            GoldenSoldier(1040, 603, 2),
            GoldenSoldier(987, 807, 2),
            GoldenSoldier(1177, 836, 2),
            GoldenSoldier(1240, 728, 2),
            GoldenSoldier(760, 971, 2),
            GoldenSoldier(1330, 1041, 2)
        ]

    class Manager {
        static activeProcedure := 0

        static AttemptNext() {
            if Placement.CURRENT > Placement.ORDER.Length
                return -1

            this.UpdateUI()
            if !INPUT_SCHEDULER.Idle
                return

            if !(this.activeProcedure is Procedure) {
                tower := Placement.ORDER[Placement.CURRENT]
                this.activeProcedure := tower.GetProcedure()
            }

            if this.activeProcedure.Done {
                Placement.CURRENT++
                this.activeProcedure := 0
                return
            }

            nextSeq := this.activeProcedure.TakeNext()
            
            if nextSeq is Sequence
                INPUT_SCHEDULER.Queue(nextSeq)
        }

        static UpdateUI() {
            UI.SetNextPlacement(Placement.ORDER[Placement.CURRENT])
            if this.activeProcedure is Procedure
                UI.SetNextCost(this.activeProcedure.NextCost)
        }

        static Reset() {
            Placement.CURRENT := 1
            this.activeProcedure := 0
        }
    }
}