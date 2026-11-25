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
        this.taskqueue := []
        this.active := 0

        Send(
            "{LButton up}{RButton up}"
            "{s up}{e up}{Escape up}{r up}{Enter up}"
            "{1 up}{2 up}"
        )
    }

    Idle {
        get => !(this.active is Sequence)
            && this.taskqueue.Length = 0
    }
}