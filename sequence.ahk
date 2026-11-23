#Requires AutoHotkey v2.0

class Sequence {
    currentStep := 0
    readyAt := 0

    __New(steps) {
        this.steps := steps
    }

    Next() {
        if A_TickCount < this.readyAt
            return true

        if this.currentStep >= this.steps.Length
            return false

        this.currentStep++
        step := this.steps[this.currentStep]

        if step.HasOwnProp("Delay") {
            this.readyAt := A_TickCount + step.Delay
            return true
        }

        step.Call()
        return true
    }

    /**
     * Concatenates another sequence at the end of this one.
     * @param seq sequence to add
     */
    Add(seq) {
        for i, step IN seq.steps 
            this.steps.Push(step)
        
        return this
    }

    class Builder {
        builder_steps := []

        AddNext(step) {
            this.builder_steps.Push(step)
            return this
        }

        AddWait(timeMs) {
            this.builder_steps.Push({Delay: timeMs})
            return this
        }

        Build() {
            return Sequence(this.builder_steps.Clone())
        }
    }
}