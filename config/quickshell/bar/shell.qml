
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower

ShellRoot {
    id: root

    property int    barHeight  : 26
    property string fontFamily : "JetBrainsMono Nerd Font"
    property int    fontSize   : 13
    property int    sideMargin : 14

    property color bg     : "#000000"
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

    property int menuWidth : 704
    property int railWidth : 132
    property int keyWidth  : 140

    property int logoWidth : 214
    property int logoSize  : 8

    property int   pollMs : 5000

    property int   dotsMs   : 2000
    property int   dotsFade : 450
    property int   wsCount  : 10

    property bool  hideOnFullscreen: true

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

    FileView {
        id: logoFile
        path: Qt.resolvedUrl("logo.txt").toString().replace("file://", "")
        blockLoading: true
    }
    readonly property string logo: logoFile.text()

    readonly property int logoLines: {
        const t = logo.replace(/\n+$/, "");
        return t === "" ? 0 : t.split("\n").length;
    }
    readonly property int logoHeight: logoLines * Math.round(logoSize * 1.25)

    property string uptime: ""
    property int    latency: -1

    readonly property color linkColor: {
        if (bars < 0)                       return fgDim;   // no radio: wired
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

    Process {
        id: uptimeProbe
        command: ["sh", "-c", "uptime -p 2>/dev/null || uptime"]
        stdout: StdioCollector {
            onStreamFinished: root.uptime = text.trim().replace(/^up /, "")
        }
    }

    onMenuOpenChanged: {
        if (!menuOpen)
            return;
        ipMenuOpen = false;
        if (!uptimeProbe.running)
            uptimeProbe.running = true;
        loadPane(menuPane);
    }

    onIpMenuOpenChanged: {
        if (!ipMenuOpen)
            return;
        menuOpen = false;
        if (!addrProbe.running) addrProbe.running = true;
        if (!latProbe.running)  latProbe.running  = true;
    }

    property string menuPane: "system"

    property var paneRows: ({})
    readonly property var currentRows: paneRows[menuPane] ?? []

    Process {
        id: paneProbe

        property string pane   : ""
        property string pending: ""

        command: [Qt.resolvedUrl("sysinfo.sh").toString().replace("file://", ""), pane]

        onRunningChanged: {
            if (running || pending === "")
                return;
            const next = pending;
            pending = "";
            root.loadPane(next);
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const rows  = [];
                const lines = text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    if (!lines[i])
                        continue;
                    const f = lines[i].split("\t");
                    if (f.length >= 2)
                        rows.push({ k: f[0], v: f[1] });
                }
                const next = {};
                for (const key in root.paneRows)
                    next[key] = root.paneRows[key];
                next[paneProbe.pane] = rows;
                root.paneRows = next;
            }
        }
    }

    function loadPane(p) {
        if (paneProbe.running) {
            paneProbe.pending = p;
            return;
        }
        paneProbe.pane = p;
        paneProbe.running = true;
    }

    onMenuPaneChanged: if (menuOpen) loadPane(menuPane)

    Component.onCompleted: if (menuOpen) loadPane(menuPane)

    function run(cmd) { Quickshell.execDetached(cmd); }
    function term(cmd) { Quickshell.execDetached(["ghostty", "-e"].concat(cmd)); }

    readonly property var menuPanes: [
        {
            id: "system", label: "System",
            apps: [
                { label: "btop",     act: function() { root.term(["btop"]); } },
                { label: "htop",     act: function() { root.term(["htop"]); } },
                { label: "Files",    act: function() { root.term(["yazi"]); } },
                { label: "Terminal", act: function() { root.run(["ghostty"]); } },
                { label: "Editor",   act: function() { root.run(["codium"]); } },
                { label: "Launcher", act: function() { root.run(["fuzzel"]); } },
            ]
        },
        {
            id: "network", label: "Network",
            apps: [
                { label: "impala",      act: function() { root.term(["impala"]); } },
                { label: "iwctl",       act: function() { root.term(["iwctl"]); } },
                { label: "Mullvad",     act: function() { root.run(["mullvad-vpn"]); } },
                { label: "qBittorrent", act: function() { root.run(["qbittorrent"]); } },
                { label: "Firefox",     act: function() { root.run(["firefox"]); } },
                { label: "Copy IP",     stay: true, act: function() { Quickshell.clipboardText = root.ip; } },
                { label: "Rescan",      stay: true, act: function() { if (!netProbe.running) netProbe.running = true;
                                                          root.loadPane("network"); } },
            ]
        },
        {
            id: "audio", label: "Audio",
            apps: [
                { label: "pavucontrol", act: function() { root.run(["pavucontrol"]); } },
                { label: "wiremix",     act: function() { root.term(["wiremix"]); } },
                { label: "cava",        act: function() { root.term(["cava"]); } },
                { label: "ncmpcpp",     act: function() { root.term(["ncmpcpp"]); } },
                { label: "Mixxx",       act: function() { root.run(["mixxx"]); } },
                { label: "mpv",         act: function() { root.run(["mpv"]); } },
            ]
        },
        {
            id: "display", label: "Display",
            apps: [
                { label: "Reload WM",   act: function() { root.run(["hyprctl", "reload"]); } },
                { label: "Wallpaper",   act: function() { root.run(["awww", "restore"]); } },
                { label: "Bright +",    stay: true, act: function() { root.run(["brightnessctl", "set", "+10%"]);
                                                          root.loadPane("display"); } },
                { label: "Bright -",    stay: true, act: function() { root.run(["brightnessctl", "set", "10%-"]);
                                                          root.loadPane("display"); } },
                { label: "Steam",       act: function() { root.run(["steam"]); } },
            ]
        },
        {
            id: "storage", label: "Storage",
            apps: [
                { label: "Files",       act: function() { root.term(["yazi"]); } },
                { label: "archive",     act: function() { root.term(["yazi", Quickshell.env("HOME") + "/archive"]); } },
                { label: "git",         act: function() { root.term(["yazi", Quickshell.env("HOME") + "/git"]); } },
                { label: "ncdu",        act: function() { root.term(["ncdu", Quickshell.env("HOME")]); } },
                { label: "qBittorrent", act: function() { root.run(["qbittorrent"]); } },
            ]
        },
    ]

    readonly property var currentPane: {
        for (let i = 0; i < menuPanes.length; i++)
            if (menuPanes[i].id === menuPane)
                return menuPanes[i];
        return menuPanes[0];
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
        function pane(which: string): string {
            let known = [];
            for (let i = 0; i < root.menuPanes.length; i++)
                known.push(root.menuPanes[i].id);
            if (known.indexOf(which) < 0)
                return "no such pane: " + which + " (have: " + known.join(" ") + ")";

            if (!root.menuOpen) {
                root.menuScreen = Hyprland.focusedMonitor?.name ?? "";
                root.menuOpen = true;
            }
            root.menuPane = which;
            return which;
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
                 + "  pane=" + root.menuPane
                 + " rows=" + root.currentRows.length
                 + "  addrs=" + root.addrList.length;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: strip

            required property var modelData

            readonly property var  hlMonitor: Hyprland.monitorFor(modelData)
            readonly property bool covered  : root.hideOnFullscreen
                && (hlMonitor?.activeWorkspace?.hasFullscreen ?? false)
            readonly property bool shown    : !root.hidden && !covered

            readonly property bool ownsMenu  : root.menuOpen   && root.menuScreen === modelData.name
            readonly property bool ownsIpMenu: root.ipMenuOpen && root.menuScreen === modelData.name
            readonly property bool anyMenu   : ownsMenu || ownsIpMenu

            readonly property int activeWs: hlMonitor?.activeWorkspace?.id ?? -1

            property bool dotsShown: false

            onActiveWsChanged: {
                if (activeWs < 0)
                    return;
                dotsShown = true;
                dotsHold.restart();
            }

            Timer {
                id: dotsHold
                interval: root.dotsMs
                onTriggered: strip.dotsShown = false
            }

            screen: modelData
            visible: shown
            color: "transparent"

            implicitHeight: root.barHeight + 420

            anchors { left: true; right: true; top: true }

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:bar"
            WlrLayershell.keyboardFocus: anyMenu
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None

            exclusiveZone: shown ? root.barHeight : 0

            mask: Region {
                width: strip.width
                height: strip.anyMenu ? strip.implicitHeight : root.barHeight
            }

            MouseArea {
                anchors.fill: parent
                visible: strip.anyMenu
                onClicked: { root.menuOpen = false; root.ipMenuOpen = false; }
            }

            Rectangle {
                id: barRect
                anchors { left: parent.left; right: parent.right; top: parent.top }
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
                        color: strip.ownsMenu ? root.white : root.fgDim
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

                Row {
                    id: wsDots

                    anchors {
                        left: nameButton.right
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 5

                    opacity: strip.dotsShown ? 1 : 0
                    visible: opacity > 0.01

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
                                root.ipMenuOpen = !root.ipMenuOpen;
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

            Item {
                id: ipMenuLayer
                visible: strip.ownsIpMenu
                anchors {
                    right: parent.right
                    rightMargin: root.sideMargin - 6
                    top: barRect.bottom
                }
                width: ipMenuBox.width + 4
                height: ipMenuBox.height + 4

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

            Item {
                id: menuLayer
                visible: strip.ownsMenu
                anchors {
                    left: parent.left
                    leftMargin: root.sideMargin - 6
                    top: barRect.bottom
                }
                width: menuBox.width + 4
                height: menuBox.height + 4

                Rectangle {
                    x: 4; y: 4
                    width: menuBox.width
                    height: menuBox.height
                    color: "#000000"
                    opacity: 0.55
                }

                Rectangle {
                    id: menuBox

                    width: root.menuWidth
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

                        Column {
                            width: parent.width
                            spacing: 1
                            bottomPadding: 5

                            Text {
                                x: 12
                                text: (Quickshell.env("USER") || "user") + "@" + root.host
                                color: root.accent
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize
                                font.bold: true
                            }
                            Text {
                                x: 12
                                text: "linux " + root.kernel + "  \u00b7  up " + root.uptime
                                color: root.fgDim
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                            }
                        }

                        Item {
                            width: parent.width
                            height: Math.max(railColumn.implicitHeight,
                                             paneColumn.implicitHeight,
                                             logoBlock.visible ? root.logoHeight + 10 : 0) + 10

                            Column {
                                id: railColumn
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    topMargin: 5
                                }
                                width: root.railWidth

                                Repeater {
                                    model: root.menuPanes

                                    Rectangle {
                                        required property var modelData

                                        readonly property bool active:
                                            modelData.id === root.menuPane

                                        width: railColumn.width
                                        height: 22
                                        color: active ? root.fgFaint : "transparent"

                                        Text {
                                            anchors {
                                                left: parent.left
                                                leftMargin: 12
                                                verticalCenter: parent.verticalCenter
                                            }
                                            text: modelData.label
                                            color: parent.active ? root.white : root.fg
                                            font.family: root.fontFamily
                                            font.pixelSize: root.fontSize
                                        }

                                        MouseArea {
                                            id: railHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onEntered: root.menuPane = modelData.id
                                            onClicked: root.menuPane = modelData.id
                                        }
                                    }
                                }
                            }

                            Text {
                                id: logoBlock

                                visible: root.menuPane === "system"
                                anchors {
                                    right: parent.right
                                    rightMargin: 12
                                    top: parent.top
                                    topMargin: 4
                                }
                                text: root.logo
                                color: root.accent
                                opacity: 0.5
                                font.family: root.fontFamily
                                font.pixelSize: root.logoSize
                                lineHeight: 1.0
                                textFormat: Text.PlainText
                            }

                            Column {
                                id: paneColumn
                                anchors {
                                    left: parent.left
                                    leftMargin: root.railWidth + 1
                                    right: parent.right
                                    rightMargin: logoBlock.visible ? root.logoWidth : 0
                                    top: parent.top
                                    topMargin: 5
                                }

                                Item {
                                    visible: root.currentRows.length === 0
                                    width: paneColumn.width
                                    height: visible ? 20 : 0

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: 12
                                            verticalCenter: parent.verticalCenter
                                        }
                                        text: paneProbe.running ? "reading\u2026"
                                                                : "no readings"
                                        color: root.fgDim
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 2
                                    }
                                }

                                Repeater {
                                    model: root.currentRows

                                    Item {
                                        required property var modelData
                                        width: paneColumn.width
                                        height: 20

                                        Text {
                                            anchors {
                                                left: parent.left
                                                leftMargin: 12
                                                verticalCenter: parent.verticalCenter
                                            }
                                            width: root.keyWidth
                                            elide: Text.ElideRight
                                            text: modelData.k
                                            color: root.fgDim
                                            font.family: root.fontFamily
                                            font.pixelSize: root.fontSize - 2
                                        }

                                        Text {
                                            anchors {
                                                left: parent.left
                                                leftMargin: 12 + root.keyWidth
                                                right: parent.right
                                                rightMargin: 12
                                                verticalCenter: parent.verticalCenter
                                            }
                                            elide: Text.ElideRight
                                            text: modelData.v
                                            color: root.white
                                            font.family: root.fontFamily
                                            font.pixelSize: root.fontSize - 1
                                        }
                                    }
                                }

                                Item { width: 1; height: 6 }

                                Item { width: 1; height: 6 }

                                Flow {
                                    x: 12
                                    width: parent.width - 24
                                    spacing: 5

                                    Repeater {
                                        model: root.currentPane.apps

                                        Rectangle {
                                            required property var modelData

                                            width: appLabel.implicitWidth + 16
                                            height: 21
                                            color: "transparent"
                                            border.width: 1
                                            border.color: appHover.containsMouse
                                                        ? root.accent : root.fgFaint
                                            radius: 0

                                            Text {
                                                id: appLabel
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: appHover.containsMouse
                                                     ? root.accent : root.fg
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize - 2
                                            }

                                            MouseArea {
                                                id: appHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (modelData.act)
                                                        modelData.act();
                                                    if (!modelData.stay)
                                                        root.menuOpen = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
        }
    }

    property string menuScreen: ""
}
