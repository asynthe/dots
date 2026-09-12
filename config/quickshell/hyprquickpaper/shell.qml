// hyprquickpaper -- wallpaper picker for Hyprland, run with
//   quickshell -c hyprquickpaper
//
// shell.qml is a fork of github.com/43PR/dotfiles (4b0412f), itself a rework of
// github.com/iamsurjog/hyprquickpaper (d380bee), where cache.sh and the
// config.json keys come from. Local changes are commented in place: full-width
// layer anchors, selection-centred zoom via StrictlyEnforceRange, endless
// scroll, opening on the current wallpaper, hover borders, a quick fade, and
// tile-shaped JPEG thumbnails.
//
// Needs: bash, jq, magick, ffmpeg, ~/.config/hypr/wallpaper.sh. See ~/git/dots/docs/WALLPAPER.md.

import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: main

    // ---- Easy-to-edit settings ----
    property int animDuration: 160    // ms for the scroll/zoom animation
    property real zoomScale: 0.8      // scale of the selected tile (peak)
    property real edgeScale: 0.3      // scale of the tiles furthest from it (trough)
    property real skewFactor: 0       // italic-style shear on tiles
    property int baseSpacing: 8       // resting gap between tiles (grows as tiles magnify)
    property int fadeDuration: 120    // ms for the open/close fade
    property int rowHeight: 720       // height of the row; a tile is this * its scale
    property int copies: 101          // folder repeats, for the endless scroll (odd number)
    // --------------------------------

    implicitHeight: rowHeight
    // Local change: upstream sets `implicitWidth: Screen.width`, which picks up
    // the wrong monitor's width on a multi-head setup (1920 panel stranded in
    // the middle of the 3440 display). Layer-shell anchors stretch the surface
    // to whichever output it lands on.
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

    // Which wallpaper is up right now, so the picker opens on it rather than
    // restarting from the middle of the folder every time.
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

        // No daemon running, or no awww at all: open on the middle, as before.
        onExited: {
            main.queryDone = true
            list.tryStart()
        }
    }

    ListView {
        id: list
        anchors.fill: parent
        focus: true

        // Endless scroll: rather than a model of `folderModel`, lay `copies` of
        // the folder end to end and start in the middle one. Each tile reads its
        // image from index % folderModel.count, so the row repeats seamlessly and
        // the ends sit thousands of tiles away in both directions. ListView only
        // builds the handful of delegates actually on screen.
        model: folderModel.count > 0 ? folderModel.count * main.copies : 0

        orientation: ListView.Horizontal
        spacing: main.baseSpacing
        clip: true
        cacheBuffer: 2000

        // The selection is driven by the keys and the wheel below, never by
        // dragging, which would only fight the centring.
        interactive: false

        // Centring is ListView's job. StrictlyEnforceRange keeps the current item
        // inside a fixed band, and the band here is exactly the selected tile's
        // width centred in the viewport -- so the selection always sits in the
        // middle of the screen, with the row fanning out either side of it.
        // (Doing this by hand meant computing contentX from item positions that
        // had not been relaid out for the new tile widths yet, which landed half a
        // tile off; and over a strip this long, summing widths in closed form
        // disagrees with ListView's own estimated coordinate space entirely.)
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width - tileWidth * main.zoomScale) / 2
        preferredHighlightEnd: (width + tileWidth * main.zoomScale) / 2
        highlightMoveDuration: main.animDuration
        currentIndex: selectedIndex

        property int selectedIndex: 0

        // Hovering a tile moves the border to it without moving the selection.
        // lastPos is what makes cycling take the border back: sliding the row
        // under a stationary cursor makes Qt deliver both entered and
        // positionChanged to whatever tile arrives under the pointer, so hover has
        // to be gated on the cursor actually moving in viewport coordinates --
        // which do not shift when the content scrolls underneath.
        property int hoverIndex: -1
        property real tileWidth: configs.number_of_pictures > 0
            ? width / configs.number_of_pictures - 10
            : 0
        // Tiles this far either side of the selection have shrunk to edgeScale.
        property real spread: Math.max(1, configs.number_of_pictures / 2)

        // Local change: upstream scales each tile by its distance from the middle
        // of the *screen*, which needs the tile's own on-screen position. Keying
        // off distance from the *selection* instead gives the same picture (the
        // selection is always centred) without the circular dependency.
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

        // The repeated strip is long but still finite, so walking far enough one
        // way would eventually reach an end. Once the selection has drifted a
        // quarter of the way out, shift it back by a whole number of copies: that
        // lands on a tile showing the same wallpaper with identical neighbours, so
        // nothing moves on screen and the row can never run out. Done without the
        // move animation, which would otherwise blur several hundred tiles past.
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

        // Open on the current wallpaper, in the middle copy of the strip. The
        // folder listing and the awww query both land asynchronously, so whichever
        // arrives last is the one that starts things.
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

        // Matched on file name rather than full path: awww echoes back the path it
        // was handed, which need not be spelled the way FolderListModel spells it.
        // Falls back to the middle of the folder when there is no match -- first
        // run, or the wallpaper on screen is not from this folder.
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

        // awww is fast (a millisecond or two), but if it were to answer with
        // neither signal -- the binary missing entirely -- the picker must not sit
        // there empty. Give up on the query after a moment and open regardless.
        Timer {
            interval: 250; running: true
            onTriggered: {
                main.queryDone = true
                list.tryStart()
            }
        }

        // One positionViewAtIndex at that moment is not enough: the view has not
        // built anything yet, so the jump lands nowhere and the picker opens on a
        // row of uniform edge-scale tiles until the first keypress makes
        // StrictlyEnforceRange do its job. Re-assert every frame until the
        // selected tile is actually centred (it also has to track the tile's width
        // animation on the way), then stop.
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

        // Local change: the picker fades itself in and out, quickly. Hyprland's
        // layer fade is one global speed shared with waybar, mako and fuzzel, so
        // it cannot be made quick for this surface alone.
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

            // Base (unscaled) slot width.
            readonly property real baseWidth: list.tileWidth
            property real scaleFactor: list.scaleAt(index)

            // The model is a plain count, so there are no roles to read - map back
            // onto the folder by hand.
            readonly property string srcFile:
                folderModel.count > 0
                    ? folderModel.get(index % folderModel.count, "fileName")
                    : ""

            // This IS the delegate's real layout width, so as it grows, ListView
            // pushes every following tile further along - real spacing, not an
            // overlapping overlay. Animated on the same curve as the scroll so the
            // row glides and the tiles swell together.
            width: baseWidth * scaleFactor
            Behavior on width {
                NumberAnimation { duration: main.animDuration; easing.type: Easing.OutCubic }
            }

            Item {
                id: content
                anchors.centerIn: parent
                width: parent.width
                // Height scale uses the same factor but caps at 1.0 - the row is
                // already full window height, so growing past that would just clip.
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
                    // Upstream disables the cache. With the endless strip the same
                    // 26 thumbnails scroll back into view constantly, and each
                    // re-created delegate would decode its file from disk again.
                    cache: true
                    smooth: true

                    // cache.sh writes "<wallpaper>.jpg" -- pre-cropped to the tile.
                    source: "file://" + configs.cache_path + delegateItem.srcFile + ".jpg"

                    // Decode once at the largest size this image will ever be
                    // shown at (the selected/zoomed size), rather than tracking
                    // the animating width/height - that would re-decode on every
                    // animation frame and cause a visible blink. Height alone:
                    // giving both dimensions made Qt decode 1720x720 to fill a
                    // 298x576 tile.
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

        // All pointer handling lives here rather than on the delegates, and it has
    // to be a sibling of the ListView, not a child: children declared inside a
    // Flickable become children of its content item and scroll away with it.
    //
    // Why not on the delegates: a delegate slides while the row animates, so one
    // stationary cursor maps to a moving coordinate and reads as mouse movement,
    // which put the border straight back under the pointer after a key cycle.
    // This surface never moves, so hover changes only when the mouse does.
    //
    // Upstream *selects* on hover; that cannot work with a centred selection
    // (moving it slides another tile under the cursor, which selects again,
    // and away it runs). Here only the border follows the mouse.
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
