#Requires AutoHotkey v2.0

class Sequence {
    currentStep := 0
    readyAt := 0
    done := false

    __New(steps) {
        this.steps := steps
    }

    Next() {
        if A_TickCount < this.readyAt
            return true

        if this.currentStep >= this.steps.Length {
            this.done := true
            return false
        }

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

    AndReset() {
        this.Add(Inputs.ResetCursorPos())
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

class Condition {
    cond := 0

    __New(cond, seq, cost := 0) {
        this.cond := cond
        this.seq := seq
        this.cost := cost
    }

    /**
     * Builds an unconditioned Condition object from the supplied sequence
     * @param seq sequence to build condition of
     */
    static of(seq) {
        return Condition(0, seq)
    }

    isPosible() {
        if this.cond = 0
            return true

        predicate := this.cond
        return predicate.Call()
    }

    SEQUENCE {
        get => this.seq
    }
}