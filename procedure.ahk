#Requires AutoHotkey v2.0
#Include sequence.ahk

class Procedure {
    currentStep := 0

    __New(conditions) {
        this.conditions := conditions
    }

    TakeNext() {
        if this.currentStep >= this.conditions.Length
            return 0

        condition := this.conditions[this.currentStep + 1]

        if !condition.isPosible()
            return 0

        this.currentStep++
        return condition.SEQUENCE
    }

    Done {
        get => this.currentStep >= this.conditions.Length
    }

    NextCost {
        get {
            if this.Done
                return 0

            return this.conditions[this.currentStep + 1].cost
        }
    }

    class Builder {
        builder_steps := []

        AddCondition(cond) {
            if !(cond is Condition)
                throw TypeError("Expected Condition, got '" cond.__Class "'")

            this.builder_steps.Push(cond)
            return this
        }

        Build() {
            return Procedure(this.builder_steps.Clone())
        }
    }
}
