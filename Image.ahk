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

    static FindImage(&x, &y, image, region) {
        global detectionTolerance

        try found := ImageSearch(&fx, &fy, region[1], region[2], region[3], region[4], "*" detectionTolerance " " image)
        catch as e {
            ToolTip "ImageSearch error: " e.Message
            return false
        }

        if !found
            return false

        x := fx
        y := fy
        CenterImgSearchCoords(image, &x, &y)
        return true
    }

    ; Waits until the image is found AND hasn't moved for stableMs.
    ; Returns the final (stable) position in x,y.
    static FindStableImage(&x, &y, image, region, timeoutMs := 5000, stableMs := 300, maxDrift := 2) {
        start := A_TickCount
        lastX := "", lastY := "", stableSince := 0

        while A_TickCount - start < timeoutMs {
            if FindImage(&cx, &cy, image, region) {
                if lastX != "" && Abs(cx - lastX) <= maxDrift && Abs(cy - lastY) <= maxDrift {
                    if A_TickCount - stableSince >= stableMs {
                        x := cx, y := cy
                        return true
                    }
                } else {
                    stableSince := A_TickCount    ; first sighting or it moved: restart the clock
                }
                lastX := cx, lastY := cy
            } else {
                lastX := ""                       ; lost it, start over
            }
            Sleep 50
        }
        return false
    }

    static CenterImgSearchCoords(img, &x, &y) {
        GetImageSize(img, &w, &h)

        x += w // 2
        y += h // 2
    }

    static GetImageSize(img, &w, &h) {
        g := Gui("-DPIScale")
        pic := g.Add("Picture", , img)
        pic.GetPos(, , &w, &h)
        g.Destroy()
    }
}