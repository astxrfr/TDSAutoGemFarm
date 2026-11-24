#Requires AutoHotkey v2.0

class State {
    static SETUP {
        get => "setup"
    }

    static READY {
        get => "ready"
    }

    static PLACING {
        get => "placement"
    }

    static END {
        get => "end"
    }

    static RESTART {
        get => "restart"
    }
}