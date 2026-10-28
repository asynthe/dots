//@ pragma IconTheme Fluent-dark

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
    id: root

    property int    barHeight  : 26
    property bool   atBottom   : false    // false: top edge, menus drop down
    property string fontFamily : "JetBrainsMono Nerd Font"
    property int    fontSize   : 14
    property int    sideMargin : 14

    property color bg     : "#ff000000"   // true OLED black, fully opaque
    property color fg     : "#c8c8c8"
    property color fgDim  : "#5a5a5a"
    property color fgFaint: "#2c2c2c"

    property color accent : "#00ff9c"
    property color warn   : "#e7c84e"
    property color crit   : "#e04f4f"
    property color white  : "#f2f2f2"

    property int   latOk  : 60
    property int   latBad : 200

    property color menuBg : "#0a0a0e"

    property int   pollMs : 5000

    property int   dotsMs   : 2000
    property int   dotsFade : 450
    property int   wsCount  : 10

    // Also bumped by the IPC flashDots() call so dots flash even when you're
    // already on that workspace (activeWorkspace.id wouldn't change).
    property int   dotsFlashGen: 0

    property bool  hideOnFullscreen: true
    property bool  hideOnGame: true
    property bool  gameRunning: false

    Process {
        id: gameProbe
        command: [Qt.resolvedUrl("game-running.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: root.gameRunning = text.trim() === "1"
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!gameProbe.running) gameProbe.running = true
    }

    property bool hidden    : false
    property bool menuOpen  : false   // the name menu, left
    property bool ipMenuOpen: false   // the address menu, right

    property int    bars : -1
    property int    rssi : 0
    property string ip   : "..."
    property string flag : ""
    property string label: ""

    readonly property bool online: ip !== "offline" && ip !== "..."

    readonly property var wsOccupied: {
        const m = {};
        const v = Hyprland.workspaces?.values ?? [];
        for (let i = 0; i < v.length; i++)
            m[v[i].id] = true;
        return m;
    }

    function isInternal(screen) {
        return /^(eDP|LVDS|DSI)/i.test(screen.name);
    }

    FileView {
        id: hostFile
        path: "/proc/sys/kernel/hostname"
        blockLoading: true
    }
    readonly property string host: hostFile.text().trim() || "?"

    FileView {
        id: kernelFile
        path: "/proc/sys/kernel/osrelease"
        blockLoading: true
    }
    readonly property string kernel: kernelFile.text().trim() || "?"

    // Dropdown content: raw `fastfetch --pipe` output (ascii logo + system
    // info in one block), fetched lazily when the menu opens.
    property string fastfetchOutput: "loading\u2026"

    Process {
        id: fastfetchProbe
        // No --logo flag: fastfetch auto-detects the running distro (NixOS,
        // Gentoo, whatever) instead of hardcoding one.
        command: ["fastfetch", "--pipe"]
        stdout: StdioCollector {
            onStreamFinished: root.fastfetchOutput = text.replace(/\n+$/, "")
        }
    }

    property int    latency: -1

    readonly property color linkColor: {
        if (bars < 0)                       return fgDim;
        if (bars <= 1 || latency < 0
            || latency > latBad)            return crit;
        if (bars === 2 || latency > latOk)  return warn;
        return accent;
    }

    readonly property var  batDev    : UPower.displayDevice
    readonly property bool batPresent: batDev !== null
        && batDev.isLaptopBattery && batDev.isPresent
    readonly property int  batPct    : batPresent
        ? Math.round(batDev.percentage * 100) : 0
    readonly property bool batOnAc   : !UPower.onBattery

    readonly property color batColor: {
        if (batOnAc)     return accent;
        if (batPct <= 15) return crit;
        if (batPct <= 30) return warn;
        return fg;
    }

    Process {
        id: netProbe
        command: [Qt.resolvedUrl("netstat.sh").toString().replace("file://", "")]

        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\t");
                if (f.length < 5)
                    return;
                root.bars  = parseInt(f[0]);
                root.rssi  = parseInt(f[1]);
                root.ip    = f[2];
                root.flag  = f[3];
                root.label = f[4];
            }
        }
    }

    Timer {
        interval: root.pollMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!netProbe.running) netProbe.running = true
    }

    Process {
        id: latProbe
        command: [Qt.resolvedUrl("latency.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(text.trim());
                root.latency = isNaN(v) ? -1 : v;
            }
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!latProbe.running) latProbe.running = true
    }

    property var addrList: []

    Process {
        id: addrProbe
        command: [Qt.resolvedUrl("addrs.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = [];
                const lines = text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    if (!lines[i])
                        continue;
                    const f = lines[i].split("\t");
                    if (f.length >= 2)
                        rows.push({ dev: f[0], addr: f[1], tag: f[2] ?? "" });
                }
                root.addrList = rows;
            }
        }
    }

    onMenuOpenChanged: {
        if (!menuOpen)
            return;
        ipMenuOpen = false;
        if (!fastfetchProbe.running)
            fastfetchProbe.running = true;
    }

    onIpMenuOpenChanged: {
        if (!ipMenuOpen)
            return;
        menuOpen = false;
        if (!addrProbe.running) addrProbe.running = true;
        if (!latProbe.running)  latProbe.running  = true;
    }

    readonly property var menuActions: [
        { label: "Reload bar", act: function() { Quickshell.reload(true); } },
        { label: "Log Out\u2026", act: function() { Hyprland.dispatch("hl.dsp.exit()"); } },
    ]

    IpcHandler {
        target: "bar"

        function toggle(): void { root.hidden = !root.hidden; root.menuOpen = false; root.ipMenuOpen = false; }
        function unhide(): void { root.hidden = false; }
        function hide(): void   { root.hidden = true; root.menuOpen = false; root.ipMenuOpen = false; }
        function poll(): void   { if (!netProbe.running) netProbe.running = true; }
        function flashDots(): void { root.dotsFlashGen++; }
        function menu(): void {
            if (!root.menuOpen)
                root.menuScreen = Hyprland.focusedMonitor?.name ?? "";
            root.menuOpen = !root.menuOpen;
        }
        function addresses(): void {
            if (!root.ipMenuOpen)
                root.menuScreen = Hyprland.focusedMonitor?.name ?? "";
            root.ipMenuOpen = !root.ipMenuOpen;
        }
        function state(): string {
            return root.bars + " bars  " + root.rssi + " dBm  "
                 + root.ip + "  " + root.flag + "  " + root.label
                 + "  | lat=" + root.latency + "ms"
                 + "  menu=" + root.menuOpen + " ipmenu=" + root.ipMenuOpen
                 + " on '" + root.menuScreen + "'"
                 + "  bat=" + (root.batPresent
                        ? root.batPct + "%" + (root.batOnAc ? " ac" : "")
                        : "none")
                 + "  ws=" + (Hyprland.focusedMonitor?.activeWorkspace?.id ?? "?")
                 + " occupied=" + Object.keys(root.wsOccupied).join(",")
                 + "  addrs=" + root.addrList.length;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: strip

            required property var modelData

            readonly property var  hlMonitor: Hyprland.monitorFor(modelData)
            readonly property bool covered  : (root.hideOnFullscreen
                && (hlMonitor?.activeWorkspace?.hasFullscreen ?? false))
                || (root.hideOnGame && root.gameRunning)
            readonly property bool shown    : !root.hidden && !covered

            readonly property int activeWs: hlMonitor?.activeWorkspace?.id ?? -1

            property bool dotsShown: false

            onActiveWsChanged: {
                if (activeWs < 0)
                    return;
                dotsShown = true;
                dotsHold.restart();
            }

            Connections {
                target: root
                function onDotsFlashGenChanged() {
                    if (Hyprland.focusedMonitor?.name !== strip.modelData.name)
                        return;
                    strip.dotsShown = true;
                    dotsHold.restart();
                }
            }

            Timer {
                id: dotsHold
                interval: root.dotsMs
                onTriggered: strip.dotsShown = false
            }

            screen: modelData
            visible: shown
            color: "transparent"

            // Fixed height: dropdowns are separate popups, so the bar never resizes.
            implicitHeight: root.barHeight

            anchors { left: true; right: true; top: !root.atBottom; bottom: root.atBottom }

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:bar"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            exclusiveZone: shown ? root.barHeight : 0

            Rectangle {
                id: barRect
                anchors {
                    left: parent.left; right: parent.right
                    top: root.atBottom ? undefined : parent.top
                    bottom: root.atBottom ? parent.bottom : undefined
                }
                height: root.barHeight
                color: root.bg

                Rectangle {
                    id: nameButton

                    anchors {
                        left: parent.left
                        leftMargin: root.sideMargin - 6
                        verticalCenter: parent.verticalCenter
                    }
                    width: nameText.implicitWidth + 12
                    height: root.barHeight - 6
                    color: "transparent"

                    Text {
                        id: nameText
                        anchors.centerIn: parent
                        text: (Quickshell.env("USER") || "user") + "@" + root.host
                        color: root.white
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.menuScreen = strip.modelData.name;
                            root.menuOpen = !root.menuOpen;
                        }
                    }
                }

                Item {
                    id: wsDotsHitbox

                    anchors {
                        left: nameButton.right
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    width: wsDots.implicitWidth
                    height: root.barHeight

                    MouseArea {
                        id: wsDotsHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }

                    Row {
                        id: wsDots
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        opacity: (strip.dotsShown || wsDotsHover.containsMouse) ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.dotsFade
                                easing.type: Easing.OutCubic
                            }
                        }

                        Repeater {
                        model: root.wsCount

                        Rectangle {
                            required property int index
                            readonly property int wsId: index + 1

                            readonly property bool isActive  : wsId === strip.activeWs
                            readonly property bool isOccupied: root.wsOccupied[wsId] === true

                            width: isActive ? 16 : 6
                            height: 6
                            radius: 0
                            anchors.verticalCenter: parent.verticalCenter

                            color: isActive   ? root.accent
                                 : isOccupied ? root.fgDim
                                              : root.fgFaint

                            Behavior on width {
                                NumberAnimation {
                                    duration: 160
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 160 }
                            }

                            MouseArea {
                                anchors {
                                    fill: parent
                                    margins: -4 // small dots get a slightly
                                }
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch(
                                    "hl.dsp.focus({ workspace = " + wsId + " })"
                                )
                            }
                        }
                        }
                    }
                }

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: root.sideMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.label
                        color: root.fgDim
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.flag === "vpn"
                        text: "vpn"
                        color: root.accent
                        opacity: 0.7
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    Rectangle {
                        id: ipButton

                        anchors.verticalCenter: parent.verticalCenter
                        width: ipRow.implicitWidth + 12
                        height: root.barHeight - 6
                        color: "transparent"

                        Row {
                            id: ipRow
                            anchors.centerIn: parent
                            spacing: 8

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Repeater {
                                    model: 4

                                    Rectangle {
                                        required property int index

                                        width: 3
                                        height: 3 + index * 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.verticalCenterOffset: (12 - height) / 2
                                        radius: 0
                                        color: index < root.bars
                                            ? root.linkColor : root.fgFaint

                                        Behavior on color {
                                            ColorAnimation { duration: 200 }
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.ip
                                color: root.online ? root.white : root.crit
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.menuScreen = strip.modelData.name;
                                root.menuOpen = !root.menuOpen;
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: root.fontSize
                        color: root.fgFaint
                    }

                    Row {
                        id: trayRow

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        visible: trayRepeater.count > 0

                        Repeater {
                            id: trayRepeater
                            model: SystemTray.items

                            Item {
                                id: trayItem
                                required property var modelData

                                width: 15
                                height: 15
                                anchors.verticalCenter: parent.verticalCenter

                                IconImage {
                                    anchors.fill: parent
                                    source: trayItem.modelData.icon
                                    smooth: true
                                    asynchronous: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton) {
                                            trayItem.modelData.activate();
                                        } else if (mouse.button === Qt.RightButton) {
                                            if (trayItem.modelData.hasMenu)
                                                trayItem.modelData.display(trayItem, 0, trayItem.height);
                                            else
                                                trayItem.modelData.secondaryActivate();
                                        } else {
                                            trayItem.modelData.secondaryActivate();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: trayRow.visible
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: root.fontSize
                        color: root.fgFaint
                    }

                    Row {
                        id: batteryGroup

                        visible: root.batPresent
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        SequentialAnimation on opacity {
                            running: batteryGroup.visible && root.batOnAc
                                && root.batPct < 100
                            loops: Animation.Infinite
                            alwaysRunToEnd: true

                            NumberAnimation {
                                from: 1; to: 0.45
                                duration: 900
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                from: 0.45; to: 1
                                duration: 900
                                easing.type: Easing.InOutSine
                            }
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Repeater {
                                model: 4

                                Rectangle {
                                    required property int index

                                    readonly property int lit:
                                        Math.ceil(root.batPct / 25)

                                    width: 3
                                    height: 9
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 0
                                    color: index < lit ? root.batColor : root.fgFaint

                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.batPct + "%"
                            color: root.batColor
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    Rectangle {
                        visible: root.batPresent
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: root.fontSize
                        color: root.fgFaint
                    }

                    SystemClock {
                        id: sysClock
                        precision: SystemClock.Minutes
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDateTime(sysClock.date, "HH:mm")
                        color: root.fg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }
                }
            }
        }
    }

    // Dropdown popups live in their own top-level windows, not inside the
    // always-visible bar strip above. This means opening one never resizes
    // the bar's own surface — no resize/repaint flash on the bar itself.
    // Outside-click-to-close relies on HyprlandFocusGrab noticing focus
    // move to a different window (clicking the toggle button again, which
    // lives on the bar's own window, closes it via its own onClicked).

    PanelWindow {
        id: menuPopup

        readonly property var targetScreen:
            Quickshell.screens.find(s => s.name === root.menuScreen) ?? null

        screen: targetScreen
        visible: root.menuOpen && targetScreen !== null
        color: "transparent"

        implicitWidth: menuBox.width + 4
        implicitHeight: menuBox.height + 4

        anchors { left: true; top: !root.atBottom; bottom: root.atBottom }
        margins {
            left: root.sideMargin - 6
            // top/bottom margin is 0: the bar's own exclusiveZone already
            // reserves barHeight px on its edge, and Hyprland auto-offsets
            // anchored-top/bottom layers past that reserved zone. Adding
            // barHeight here again double-counts it.
        }

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:bar"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusiveZone: 0

        HyprlandFocusGrab {
            active: menuPopup.visible
            windows: [menuPopup]
            onCleared: root.menuOpen = false
        }

        Rectangle {
            x: 4; y: 4
            width: menuBox.width
            height: menuBox.height
            color: "#000000"
            opacity: 0.55
        }

        Rectangle {
            id: menuBox

            width: Math.max(fastfetchText.implicitWidth + 24, 260)
            height: menuColumn.implicitHeight + 12
            color: root.menuBg
            border.width: 0
            radius: 0

            Column {
                id: menuColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 6
                }

                Text {
                    id: fastfetchText
                    x: 12
                    text: root.fastfetchOutput
                    color: root.fg
                    font.family: "monospace"
                    font.pixelSize: root.fontSize - 2
                    lineHeight: 1.1
                    textFormat: Text.PlainText
                    wrapMode: Text.NoWrap
                }

                Item {
                    width: parent.width
                    height: 24

                    Row {
                        anchors {
                            right: parent.right
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 4

                        Repeater {
                            model: root.menuActions

                            Rectangle {
                                required property var modelData

                                width: actLabel.implicitWidth + 16
                                height: 20
                                color: "transparent"

                                Text {
                                    id: actLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: actHover.containsMouse
                                         ? root.accent : root.fgDim
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                }

                                MouseArea {
                                    id: actHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.menuOpen = false;
                                        if (modelData.act)
                                            modelData.act();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        id: ipMenuPopup

        readonly property var targetScreen:
            Quickshell.screens.find(s => s.name === root.menuScreen) ?? null

        screen: targetScreen
        visible: root.ipMenuOpen && targetScreen !== null
        color: "transparent"

        implicitWidth: ipMenuBox.width + 4
        implicitHeight: ipMenuBox.height + 4

        anchors { right: true; top: !root.atBottom; bottom: root.atBottom }
        margins {
            right: root.sideMargin - 6
        }

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:bar"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusiveZone: 0

        HyprlandFocusGrab {
            active: ipMenuPopup.visible
            windows: [ipMenuPopup]
            onCleared: root.ipMenuOpen = false
        }

        Rectangle {
            x: 4; y: 4
            width: ipMenuBox.width
            height: ipMenuBox.height
            color: "#000000"
            opacity: 0.55
        }

        Rectangle {
            id: ipMenuBox

            width: 300
            height: ipColumn.implicitHeight + 12
            color: root.menuBg
            border.width: 0
            radius: 0

            Column {
                id: ipColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 6
                }

                Text {
                    x: 12
                    text: "Addresses"
                    color: root.linkColor
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                    bottomPadding: 5
                }

                Repeater {
                    model: root.addrList

                    Item {
                        required property var modelData
                        width: ipColumn.width
                        height: 22

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                text: modelData.dev
                                color: addrHover.containsMouse ? root.linkColor : root.fgDim
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 1
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 118
                                    verticalCenter: parent.verticalCenter
                                }
                                text: modelData.addr
                                color: addrHover.containsMouse ? root.linkColor : root.white
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize
                            }

                            Text {
                                anchors {
                                    right: parent.right
                                    rightMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                text: modelData.tag
                                color: modelData.tag === "default" ? root.accent : root.fgFaint
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 3
                            }

                            MouseArea {
                                id: addrHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Quickshell.clipboardText = modelData.addr;
                                    root.ipMenuOpen = false;
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 22

                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text: "signal"
                        color: root.fgDim
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 1
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: 118; verticalCenter: parent.verticalCenter }
                        text: root.bars < 0 ? "wired" : root.rssi + " dBm"
                        color: root.linkColor
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }
                }

                Item {
                    width: parent.width
                    height: 22

                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text: "latency"
                        color: root.fgDim
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 1
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: 118; verticalCenter: parent.verticalCenter }
                        text: root.latency < 0 ? "no reply" : root.latency + " ms"
                        color: root.latency < 0 ? root.crit
                             : (root.latency > root.latBad ? root.crit
                             : (root.latency > root.latOk ? root.warn : root.accent))
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }
                }
            }
        }
    }

    property string menuScreen: ""
}
