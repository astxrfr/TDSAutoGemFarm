#Requires AutoHotkey v2.0
#Include sequence.ahk

class InputScheduler {
    taskqueue := []
    active := 0
    locked := false

    Queue(sequence) {
        this.taskqueue.Push(sequence)
    }

    Tick() {
        if this.locked
            return

        if !(this.active is Sequence) {
            if this.taskqueue.Length = 0
                return

            this.active := this.taskqueue.RemoveAt(1)
        }   

        if !this.active.Next()
            this.active := 0
    }

    Reset() {
        this.locked := true
        this.taskqueue := []
        this.active := 0
        this.locked := false
    }

    Idle {
        get => !(this.active is Sequence)
            && this.taskqueue.Length = 0
    }
}