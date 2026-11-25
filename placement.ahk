#Requires AutoHotkey v2.0
#Include towers\GPyromancer.ahk
#Include towers\GSoldier.ahk

class Placement {
    static CURRENT := 1
    static ORDER := [
            GoldenPyromancer(847, 475, 2),
            GoldenSoldier(738, 669, 2),
            GoldenSoldier(851, 693, 2),
            GoldenSoldier(993, 721, 2),
            GoldenSoldier(1162, 746, 2),
            GoldenSoldier(778, 566, 2),
            GoldenPyromancer(1165, 576, 2),
            GoldenSoldier(866, 572, 2),
            GoldenSoldier(961, 577, 2),
            GoldenSoldier(918, 542, 2),
            GoldenSoldier(1345, 783, 2),
            GoldenSoldier(790, 793, 2),
            GoldenSoldier(618, 1013, 2),
            GoldenSoldier(677, 581, 2),
            GoldenSoldier(1405, 1051, 2),
            GoldenSoldier(1268, 602, 2),
            GoldenSoldier(586, 709, 2)
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