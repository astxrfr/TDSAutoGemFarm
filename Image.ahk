#Requires AutoHotkey v2.0

class Image {
    static dir := A_ScriptDir . "\image\"

    class Landscape {
        static SPOT_1 {
            get => Image.dir "GateSpot1.png"
        } 
    }

    class Button {
        static READY { 
            get => Image.dir "READYButton.png" 
        }
        static SKIP {
            get => Image.dir "waveSkipButton.png"
        }
    }
}