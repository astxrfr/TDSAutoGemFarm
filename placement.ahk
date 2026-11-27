#Requires AutoHotkey v2.0
#Include config.ahk

class Placement {
    static CURRENT := 1
    static ORDER := Config.STRAT

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