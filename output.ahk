#Requires AutoHotkey v2.0

ResetCursorPos() {
    MouseMove(A_ScreenWidth//4*3, A_ScreenHeight//2, 10)
}

ClickAt(x, y) {
    MouseMove x, y, 8
    Sleep 10
    Click "down"
    Sleep 20
    Click "up"
}

PlaceTower(x, y, slot) {

}