#Requires AutoHotkey v2.0
#Include scheduler.ahk
#Include sequence.ahk

class InputScheduler {
    taskqueue := []
    active := 0

    Queue(sequence) {
        this.taskqueue.Push(sequence)
    }

    Tick() {
        if !(this.active is Sequence) {
            if this.taskqueue.Length = 0
                return

            this.active := this.taskqueue.RemoveAt(1)
        }   

        if !this.active.Next()
            this.active := 0
    }
}