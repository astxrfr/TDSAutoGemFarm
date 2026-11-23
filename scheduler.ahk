#Requires AutoHotkey v2.0

class Scheduler {
    taskqueue := []
    locked := false

    Lock() {
        this.locked := true
    }

    Release() {
        this.locked := false
    }

    Next() {
        if this.taskqueue.Length = 0 OR this.locked
            return

        next := this.taskqueue.RemoveAt(1)
        this.Lock()
        next.Call()
        this.Release()
    }

    Queue(task) {
        this.taskqueue.Push(task)
    }
}