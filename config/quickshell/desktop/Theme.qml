pragma Singleton

import QtQuick
import Quickshell

// Windows 11 look, OLED black, for the desktop icons and their menus.
Singleton {
    readonly property string font: {
        const have = Qt.fontFamilies();
        for (const f of ["Segoe UI", "Selawik", "Noto Sans"])
            if (have.includes(f))
                return f;
        return "sans-serif";
    }
    readonly property int textSize: 13

    readonly property color fg    : "#ffffff"
    readonly property color accent: "#0078d7"

    readonly property color menuBg    : "#000000"
    readonly property color menuHover : "#1f1f1f"
    readonly property color menuBorder: "#333333"
    readonly property color menuSep   : "#2a2a2a"

    readonly property color deskHover    : Qt.rgba(0.6, 0.82, 1, 0.18)
    readonly property color deskSel      : Qt.rgba(0.6, 0.82, 1, 0.34)
    readonly property color deskSelBorder: Qt.rgba(0.6, 0.82, 1, 0.55)
}
