
import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: main

    property int animDuration: 160    // ms for the scroll/zoom animation
    property real zoomScale: 0.8      // scale of the selected tile (peak)
    property real edgeScale: 0.3      // scale of the tiles furthest from it (trough)
    property real skewFactor: 0       // italic-style shear on tiles
    property int baseSpacing: 8       // resting gap between tiles (grows as tiles magnify)
    property int fadeDuration: 120    // ms for the open/close fade
    property int rowHeight: 720       // height of the row; a tile is this * its scale
    property int copies: 101          // folder repeats, for the endless scroll (odd number)

    implicitHeight: rowHeight
    anchors.left: true
    anchors.right: true
    color: "transparent"

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Component.onCompleted: {
        Quickshell.execDetached(["bash", Quickshell.shellPath("cache.sh"), Quickshell.shellDir])
    }

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: configs
            property string wallpaper_path
            property string cache_path
            property int number_of_pictures
            property string border_color
        }
    }

    FolderListModel {
        id: folderModel
        folder: configs.wallpaper_path ? "file://" + configs.wallpaper_path : ""
        showDirs: false
        nameFilters: ["*.png", "*.jpg", "*.jpeg"]
        sortField: FolderListModel.Name
    }

    property string currentWallpaper: ""
    property bool queryDone: false

    Process {
        running: true
        command: ["bash", "-c",
            "cat \"${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/current-wallpaper\" 2>/dev/null | grep . || awww query"]

        stdout: StdioCollector {
            id: currentQuery
            onStreamFinished: {
                const out = currentQuery.text.trim()
                const m = /image:\s*(.+)/.exec(out)
                main.currentWallpaper = m ? m[1].trim()
                    : (out.startsWith("/") ? out.split("\n")[0].trim() : "")
                main.queryDone = true
                list.tryStart()
            }
        }

        onExited: {
            main.queryDone = true
            list.tryStart()
        }
    }

    ListView {
        id: list
        anchors.fill: parent
        focus: true

        model: folderModel.count > 0 ? folderModel.count * main.copies : 0

        orientation: ListView.Horizontal
        spacing: main.baseSpacing
        clip: true
        cacheBuffer: 2000

        interactive: false

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width - tileWidth * main.zoomScale) / 2
        preferredHighlightEnd: (width + tileWidth * main.zoomScale) / 2
        highlightMoveDuration: main.animDuration
        currentIndex: selectedIndex

        property int selectedIndex: 0

        property int hoverIndex: -1
        property real tileWidth: configs.number_of_pictures > 0
            ? width / configs.number_of_pictures - 10
            : 0
        property real spread: Math.max(1, configs.number_of_pictures / 2)

        function scaleAt(i) {
            const d = Math.min(1, Math.abs(i - selectedIndex) / spread)
            const t = 1 - d * d * (3 - 2 * d)      // smoothstep falloff
            return main.edgeScale + (main.zoomScale - main.edgeScale) * t
        }

        function clampIndex(i) {
            return Math.max(0, Math.min(i, count - 1))
        }

        function moveSelection(delta) {
            hoverIndex = -1
            selectedIndex = clampIndex(selectedIndex + delta)
            rebase()
        }

        function rebase() {
            const n = folderModel.count
            if (n === 0) return
            const middle = n * Math.floor(main.copies / 2)
            const drift = selectedIndex - (middle + selectedIndex % n)
            if (Math.abs(drift) < n * Math.floor(main.copies / 4)) return
            highlightMoveDuration = 0
            selectedIndex -= drift
            highlightMoveDuration = main.animDuration
        }

        function activateCurrent() {
            const path = folderModel.get(selectedIndex % folderModel.count, "filePath")
            Quickshell.execDetached(["bash", Quickshell.shellPath("commands.sh"), path])
            fadeOut.start()
        }

        property bool started: false
        onCountChanged: tryStart()

        function tryStart() {
            if (started || folderModel.count === 0 || !main.queryDone) return
            started = true
            const n = folderModel.count
            highlightMoveDuration = 0
            selectedIndex = n * Math.floor(main.copies / 2) + indexOfCurrent()
            settle.tries = 0
            settle.running = true
        }

        function indexOfCurrent() {
            const n = folderModel.count
            const cur = main.currentWallpaper
            const want = cur.substring(cur.lastIndexOf("/") + 1)
            if (want !== "") {
                for (let i = 0; i < n; i++) {
                    if (folderModel.get(i, "fileName") === want) return i
                }
            }
            return Math.floor((n - 1) / 2)
        }

        Timer {
            interval: 250; running: true
            onTriggered: {
                main.queryDone = true
                list.tryStart()
            }
        }

        Timer {
            id: settle
            interval: 16; repeat: true; running: false
            property int tries: 0
            onTriggered: {
                list.positionViewAtIndex(list.selectedIndex, ListView.Center)
                const it = list.itemAtIndex(list.selectedIndex)
                const centred = it && Math.abs(it.x - list.contentX + it.width / 2
                                               - list.width / 2) < 2
                if (centred || ++tries > 40) {
                    running = false
                    list.highlightMoveDuration = main.animDuration
                }
            }
        }

        opacity: 0
        Component.onCompleted: fadeIn.start()

        NumberAnimation {
            id: fadeIn
            target: list; property: "opacity"; to: 1
            duration: main.fadeDuration; easing.type: Easing.OutQuad
        }

        NumberAnimation {
            id: fadeOut
            target: list; property: "opacity"; to: 0
            duration: main.fadeDuration; easing.type: Easing.InQuad
            onFinished: Qt.quit()
        }

        delegate: Item {
            id: delegateItem
            height: main.rowHeight
            property bool active: index === list.selectedIndex

            readonly property real baseWidth: list.tileWidth
            property real scaleFactor: list.scaleAt(index)

            readonly property string srcFile:
                folderModel.count > 0
                    ? folderModel.get(index % folderModel.count, "fileName")
                    : ""

            width: baseWidth * scaleFactor
            Behavior on width {
                NumberAnimation { duration: main.animDuration; easing.type: Easing.OutCubic }
            }

            Item {
                id: content
                anchors.centerIn: parent
                width: parent.width
                height: delegateItem.height * Math.min(1, delegateItem.scaleFactor)

                Text {
                    id: alt
                    text: ""
                    color: configs.border_color
                    anchors.centerIn: parent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 19
                    transform: Shear { xFactor: main.skewFactor }
                }

                Image {
                    id: img
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop

                    asynchronous: true
                    cache: true
                    smooth: true

                    source: "file://" + configs.cache_path + delegateItem.srcFile + ".jpg"

                    sourceSize.height: main.rowHeight * main.zoomScale

                    transform: Shear { xFactor: main.skewFactor }

                    Timer {
                        id: retryTimer
                        interval: 1000
                        repeat: false
                        onTriggered: {
                            const s = img.source
                            img.source = ""
                            img.source = s
                        }
                    }

                    onStatusChanged: {
                        if (status === Image.Error) {
                            alt.text = "Caching"
                            retryTimer.start()
                        }
                    }
                }

                Rectangle {
                    id: border
                    z: 10
                    anchors.fill: parent
                    visible: list.hoverIndex === -1
                        ? delegateItem.active
                        : list.hoverIndex === index
                    color: "transparent"

                    border.width: 2
                    border.color: configs.border_color

                    transform: Shear { xFactor: main.skewFactor }
                }
            }

        }

        Keys.onPressed: function(event) {
            const big = configs.number_of_pictures

            switch (event.key) {
            case Qt.Key_L:
            case Qt.Key_Right:
            case Qt.Key_J:
            case Qt.Key_Period:
                moveSelection(1)
                break
            case Qt.Key_H:
            case Qt.Key_Left:
            case Qt.Key_K:
            case Qt.Key_Comma:
                moveSelection(-1)
                break
            case Qt.Key_D:
                moveSelection(big)
                break
            case Qt.Key_U:
                moveSelection(-big)
                break
            case Qt.Key_Space:
            case Qt.Key_Return:
                activateCurrent()
                break
            case Qt.Key_Escape:
                fadeOut.start()
                break
            default:
                return
            }

            event.accepted = true
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        z: 100

        function tileUnder(x, y) {
            return list.indexAt(list.contentX + x, list.contentY + y)
        }

        onPositionChanged: function(mouse) {
            list.hoverIndex = tileUnder(mouse.x, mouse.y)
        }
        onExited: list.hoverIndex = -1

        onClicked: function(mouse) {
            const i = tileUnder(mouse.x, mouse.y)
            if (i < 0) return
            list.selectedIndex = i
            list.activateCurrent()
        }

        onWheel: function(wheel) {
            list.moveSelection(wheel.angleDelta.y > 0 ? -1 : 1)
            wheel.accepted = true
        }
    }
}
