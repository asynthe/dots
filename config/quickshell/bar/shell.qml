//@ pragma UseQApplication

// ───────────────────────── Minimal Hyprland bar ─────────────────────────
//
// Layout is decided by a screen's *role*, never by its name:
//
//   main    -- workspaces (left), clock (centre), tray (right)
//   laptop  -- clock (centre), battery (right)
//
// "Main" is the widest external output, or the laptop panel when nothing is
// plugged in -- so plugging the ultrawide in moves the workspaces and tray to
// it and leaves the laptop with time and battery. The battery only ever lives
// on the laptop's own bar; when the laptop *is* main it carries the full set.
//
// UseQApplication is required by QsMenuAnchor -- tray menus are platform
// menus, and QGuiApplication cannot build them.
//
// A bar tucks itself away while its screen shows a fullscreen window, so games
// -- which ../../hypr/hyprland.lua forces fullscreen -- get the whole output.
//
// Run:    qs -c bar
// Toggle: qs -c bar ipc call bar toggle   (bound in ../../hypr/hyprland.lua)

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray

ShellRoot {
    id: root

    // ───────────────────────── Settings ─────────────────────────
    property int    barHeight  : 34
    property string fontFamily : "JetBrainsMono Nerd Font"
    property int    fontSize   : 16
    property int    sideMargin : 16
    property int    shadowHeight: 14

    property color bg      : "#870d0d12"  // ARGB: ~53% of ghostty's tint
    property color fg      : "#ffffff"
    property color fgDim   : "#6a6a6a"
    property color fgFaint : "#2a2a2a"
    property color accent  : "#8a5cd6"    // rgb(451F67), the hyprland active border, lifted to read on black
    property color warn    : "#e78a4e"    // waybar's warning orange
    property color crit    : "#e04f4f"

    property int animFast : 160
    property int animSlow : 260

    // Get out of the way of fullscreen windows. The bar is on the Top layer,
    // which Hyprland still draws over a fullscreen client, so this is on us.
    property bool hideOnFullscreen: true

    // Source address of the default route. With Mullvad up this is the tunnel
    // address, which is normally what "my current IP" means; swap in
    // `hostname -I | cut -d' ' -f1` if you want the LAN address instead.
    property string ipCommand: "ip -4 route get 1.1.1.1 | sed -n 's/.*src \\([0-9.]*\\).*/\\1/p'"
    // ────────────────────────────────────────────────────────────

    property bool   hidden   : false
    // Summoned over a fullscreen window by the toggle. Cleared on the way out.
    property bool   overFull : false
    property bool   showIp   : false
    property string ipAddress: "..."

    // The panel behind the lid. eDP/LVDS/DSI is the kernel's naming for an
    // internal display, so this outlives any particular laptop -- unlike the
    // "AU Optronics 0xB0AE" match in hypr/monitors.lua.
    function isInternal(screen) {
        return /^(eDP|LVDS|DSI)/i.test(screen.name);
    }

    // What the toggle acts on -- the bar you are looking at is the one on the
    // monitor with focus.
    readonly property bool focusedFullscreen:
        Hyprland.focusedMonitor?.activeWorkspace?.hasFullscreen ?? false

    // Widest external if one is plugged in, else the internal panel.
    readonly property var mainScreen: {
        const all = Quickshell.screens;
        let best = null;
        for (let i = 0; i < all.length; i++) {
            const s = all[i];
            if (root.isInternal(s))
                continue;
            if (best === null || s.width > best.width)
                best = s;
        }
        if (best !== null)
            return best;
        return all.length > 0 ? all[0] : null;
    }

    // ───────────────────────── Hide toggle ─────────────────────────
    IpcHandler {
        target: "bar"

        // Under a fullscreen window the toggle flips the override rather than
        // `hidden`, so one keypress always swaps what you can actually see.
        function toggle(): void {
            if (root.hideOnFullscreen && root.focusedFullscreen) {
                root.overFull = !root.overFull;
                root.hidden = false;
            } else {
                root.hidden = !root.hidden;
            }
        }
        // Not `show` -- quickshell 0.3.0 silently drops an IPC function by that
        // name; it never appears in `qs -c bar ipc show bar`.
        function unhide(): void {
            root.hidden = false;
            root.overFull = true;
        }
        function hide(): void {
            root.hidden = true;
            root.overFull = false;
        }
    }

    // ───────────────────────── Address probe ─────────────────────────
    Process {
        id: ipProbe
        command: ["sh", "-c", root.ipCommand]

        stdout: StdioCollector {
            onStreamFinished: root.ipAddress = text.trim() || "offline"
        }
    }

    Component.onCompleted: ipProbe.running = true
    // Re-probe on every flip, so a click never shows a stale address.
    onShowIpChanged: if (showIp)
        ipProbe.running = true

    // ───────────────────────── The bars ─────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            readonly property bool isMain    : modelData === root.mainScreen
            readonly property bool isInternal: root.isInternal(modelData)

            // This screen's own workspace, not the focused one: a game on the
            // ultrawide should not blank the laptop's clock.
            readonly property var  hlMonitor : Hyprland.monitorFor(modelData)
            readonly property bool covered   : root.hideOnFullscreen
                && !root.overFull
                && (hlMonitor?.activeWorkspace?.hasFullscreen ?? false)

            readonly property bool shown     : !root.hidden && !covered

            // 1 = out, 0 = tucked below the screen edge. Driven imperatively so
            // the Behavior animates it; a plain binding would just snap.
            property real reveal: 0
            onShownChanged: reveal = shown ? 1 : 0
            Component.onCompleted: reveal = shown ? 1 : 0

            screen: modelData
            visible: reveal > 0.01
            color: "transparent"
            implicitHeight: root.barHeight + root.shadowHeight

            anchors {
                left: true
                right: true
                top: true
            }

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:bar"

            mask: Region {
                width: bar.width
                height: root.barHeight
            }

            // Stepped rather than tied to `reveal`: one resize for Hyprland to
            // animate on its own, instead of a reflow on every frame of the slide.
            exclusiveZone: shown ? root.barHeight : 0

            Behavior on reveal {
                NumberAnimation {
                    duration: root.animSlow
                    easing.type: Easing.OutCubic
                }
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: root.barHeight
                opacity: bar.reveal

                transform: Translate {
                    y: -(1 - bar.reveal) * root.barHeight
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.bg
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.bottom
                    }
                    height: root.shadowHeight

                    gradient: Gradient {
                        GradientStop { position: 0.00; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, root.bg.a) }
                        GradientStop { position: 0.15; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, root.bg.a * 0.68) }
                        GradientStop { position: 0.30; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, root.bg.a * 0.44) }
                        GradientStop { position: 0.50; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, root.bg.a * 0.21) }
                        GradientStop { position: 0.70; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, root.bg.a * 0.085) }
                        GradientStop { position: 1.00; color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0) }
                    }
                }

                // ───────────────────────── Left: workspaces ─────────────────────────
                Row {
                    visible: bar.isMain
                    spacing: 7

                    anchors {
                        left: parent.left
                        leftMargin: root.sideMargin
                        verticalCenter: parent.verticalCenter
                    }

                    // Ten fixed slots, matching waybar's `persistent_workspaces: {"*": 10}`.
                    // Hyprland only reports workspaces that exist, so the empty ones
                    // would otherwise pop in and out as you move around.
                    Repeater {
                        model: 10

                        // The slot is the click target and is only as wide as its dot,
                        // so the row still collapses to the pill-and-dots shape -- but
                        // it spans the full bar height, and the hit areas stop half a
                        // gap short of each other instead of overlapping by 5px.
                        Item {
                            id: slot

                            required property int index
                            readonly property int wsId: index + 1

                            readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId

                            // Reads `values` directly rather than through a helper, so
                            // the binding picks up a dependency on the model changing.
                            readonly property bool occupied: {
                                const list = Hyprland.workspaces.values;
                                for (let i = 0; i < list.length; i++) {
                                    if (list[i].id === slot.wsId)
                                        return true;
                                }
                                return false;
                            }

                            width: dot.width
                            height: root.barHeight

                            Rectangle {
                                id: dot

                                anchors.centerIn: parent
                                width: slot.focused ? 20 : 7
                                height: 7
                                radius: height / 2
                                color: slot.focused ? root.accent : slot.occupied ? root.fgDim : root.fgFaint
                                opacity: hit.containsMouse && !slot.focused ? 1 : 0.85

                                Behavior on width {
                                    NumberAnimation {
                                        duration: root.animFast
                                        easing.type: Easing.OutBack
                                    }
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: root.animFast
                                    }
                                }
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: root.animFast
                                    }
                                }
                            }

                            MouseArea {
                                id: hit

                                anchors.fill: parent
                                anchors.leftMargin: -3   // half the row spacing, so a 7px dot is still hittable
                                anchors.rightMargin: -3
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                // Hyprland is on the lua parser here, so a dispatch is
                                // evaluated as lua -- the legacy "workspace 3" string
                                // comes back as `hl.dispatch(workspace 3)` and fails to
                                // compile. This is the same call hyprland.lua's ALT+<n>
                                // binds make.
                                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + slot.wsId + " })")
                            }
                        }
                    }
                }

                // ───────────────────────── Centre: clock / address ─────────────────────────
                Item {
                    id: clock

                    anchors.centerIn: parent
                    height: root.barHeight
                    width: root.showIp ? ipLabel.implicitWidth : timeLabel.implicitWidth

                    Behavior on width {
                        NumberAnimation {
                            duration: root.animSlow
                            easing.type: Easing.OutCubic
                        }
                    }

                    SystemClock {
                        id: sysClock
                        precision: SystemClock.Minutes
                    }

                    // Clipped so the two labels slide past the brackets instead of
                    // spilling over the workspaces while the width catches up.
                    Item {
                        anchors.fill: parent
                        clip: true

                        Text {
                            id: timeLabel

                            anchors.centerIn: parent
                            text: "[ " + Qt.formatDateTime(sysClock.date, "hh:mm ap") + " ]"
                            color: root.fg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            opacity: root.showIp ? 0 : 1

                            transform: Translate {
                                y: root.showIp ? -root.barHeight / 2 : 0

                                Behavior on y {
                                    NumberAnimation {
                                        duration: root.animSlow
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animFast
                                }
                            }
                        }

                        Text {
                            id: ipLabel

                            anchors.centerIn: parent
                            text: "[ " + root.ipAddress + " ]"
                            color: root.accent
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            opacity: root.showIp ? 1 : 0

                            transform: Translate {
                                y: root.showIp ? 0 : root.barHeight / 2

                                Behavior on y {
                                    NumberAnimation {
                                        duration: root.animSlow
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animFast
                                }
                            }
                        }
                    }

                    // Sibling of the clipper, not a child: Qt Quick hit-tests against
                    // the clip rect, so a MouseArea inside it would lose the margins.
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showIp = !root.showIp
                    }
                }

                // ───────────────────────── Right: tray, battery ─────────────────────────
                Row {
                    spacing: 14

                    anchors {
                        right: parent.right
                        rightMargin: root.sideMargin
                        verticalCenter: parent.verticalCenter
                    }

                    Row {
                        visible: bar.isMain
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: SystemTray.items

                            MouseArea {
                                id: trayEntry

                                required property var modelData

                                width: 18
                                height: 18
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                                // nm-applet and mullvad are menu-only items -- activate()
                                // does nothing for them, so left-click has to open the menu.
                                onClicked: event => {
                                    const wantsMenu = event.button === Qt.RightButton || (event.button === Qt.LeftButton && modelData.onlyMenu);
                                    if (wantsMenu) {
                                        if (modelData.hasMenu)
                                            trayMenu.open();
                                    } else if (event.button === Qt.MiddleButton) {
                                        modelData.secondaryActivate();
                                    } else {
                                        modelData.activate();
                                    }
                                }

                                QsMenuAnchor {
                                    id: trayMenu
                                    menu: trayEntry.modelData.menu
                                    anchor.item: trayEntry
                                    anchor.edges: Edges.Bottom
                                    anchor.gravity: Edges.Bottom
                                }

                                IconImage {
                                    anchors.fill: parent
                                    source: trayEntry.modelData.icon
                                    opacity: trayEntry.containsMouse ? 1 : 0.7
                                    scale: trayEntry.containsMouse ? 1.18 : 1

                                    // Adwaita draws symbolic icons as a near-black
                                    // glyph (#2e3436) and expects the consumer to
                                    // recolour them -- GTK does, Qt does not, so on a
                                    // black bar they arrive invisible. Full-colour
                                    // icons (steam, qbittorrent) must be left alone,
                                    // hence the name test rather than a blanket tint.
                                    readonly property bool symbolic: String(trayEntry.modelData.icon).includes("-symbolic")

                                    layer.enabled: symbolic
                                    layer.effect: MultiEffect {
                                        // brightness, not colorization: colorization
                                        // scales by source luminance, so a #2e3436
                                        // glyph stays #2e3436. Saturating brightness
                                        // pushes it to white and leaves alpha intact.
                                        brightness: 1
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: root.animFast
                                        }
                                    }
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: root.animFast
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        id: battery

                        readonly property var dev: UPower.displayDevice
                        readonly property bool present: dev !== null && dev.isLaptopBattery && dev.isPresent
                        readonly property int pct: present ? Math.round(dev.percentage * 100) : 0
                        readonly property bool charging: present && dev.state === UPowerDeviceState.Charging
                        // waybar shows the bolt for charging, full *and* plugged, so
                        // key it off AC rather than the charging state alone.
                        readonly property bool onAc: !UPower.onBattery

                        // The laptop's own bar, wherever that happens to be.
                        visible: bar.isInternal && present
                        spacing: 7
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: batteryIcon

                            // Font Awesome, the same glyphs waybar's battery module
                            // uses -- f244..f240 are empty..full and f0e7 is the bolt
                            // it shows for charging/full/plugged. They live in the
                            // nerd font the rest of the bar already uses, so there is
                            // no second family to fall back to.
                            text: {
                                if (battery.onAc)
                                    return "\uf0e7";
                                const p = battery.pct;
                                if (p < 20)
                                    return "\uf244";
                                if (p < 40)
                                    return "\uf243";
                                if (p < 60)
                                    return "\uf242";
                                if (p < 80)
                                    return "\uf241";
                                return "\uf240";
                            }

                            color: battery.onAc ? root.accent : battery.pct <= 15 ? root.crit : battery.pct <= 30 ? root.warn : root.fg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.animSlow
                                }
                            }

                            // A glyph swap is a step change, so give it a small pop to
                            // land on rather than having it blink to the next shape.
                            onTextChanged: pop.restart()

                            SequentialAnimation {
                                id: pop

                                NumberAnimation {
                                    target: batteryIcon
                                    property: "scale"
                                    to: 1.25
                                    duration: root.animFast
                                    easing.type: Easing.OutBack
                                }
                                NumberAnimation {
                                    target: batteryIcon
                                    property: "scale"
                                    to: 1
                                    duration: root.animFast
                                    easing.type: Easing.OutCubic
                                }
                            }

                            // Pulses only while actually filling, so a machine left
                            // docked at 100% shows a steady bolt. Ends on 1 because the
                            // cycle runs back to it and alwaysRunToEnd lets the current
                            // pass finish -- unplugging cannot strand the icon dimmed.
                            SequentialAnimation on opacity {
                                running: battery.charging
                                loops: Animation.Infinite
                                alwaysRunToEnd: true

                                NumberAnimation {
                                    from: 1
                                    to: 0.4
                                    duration: 900
                                    easing.type: Easing.InOutSine
                                }
                                NumberAnimation {
                                    from: 0.4
                                    to: 1
                                    duration: 900
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }

                        Text {
                            text: battery.pct + "%"
                            color: root.fgDim
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
