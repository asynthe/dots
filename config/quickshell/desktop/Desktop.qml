import QtQuick
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// Icons for XDG_DESKTOP_DIR on the bottom layer: above the wallpaper, below windows.
PanelWindow {
    id: desk

    required property var modelData
    screen: modelData

    readonly property string dir: Ui.dir("DESKTOP")
    property var    items   : []
    property var    sel     : ({})
    property string renaming: ""
    property string pending : ""       // new item to rename once it shows up
    property var    games   : ({})     // .desktop names that start games (no float, no fade)

    property bool   dragging: false
    property real   dragDx  : 0
    property real   dragDy  : 0
    property string dropOn  : ""
    property bool   dropped : false    // swallow the click that ends a drag

    readonly property int pitchX: 78
    readonly property int pitchY: 96
    readonly property int cols  : Math.max(1, Math.floor((width - 8) / pitchX))
    readonly property int rows  : Math.max(1, Math.floor((height - 8) / pitchY))

    FileView {
        path: Quickshell.statePath("desktop.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => { if (error === FileViewError.FileNotFound) writeAdapter(); }
        JsonAdapter { id: layout; property var screens: ({}) }   // screen -> { file name -> [col, row] }
    }
    // each screen keeps its own arrangement, like Windows does per display
    readonly property var slots: layout.screens?.[modelData.name] ?? ({})
    function saveSlots(s) {
        const all = Object.assign({}, layout.screens);
        all[modelData.name] = s;
        layout.screens = all;
    }

    // Saved cells first, the rest fill free cells top-down, left to right.
    readonly property var placed: {
        const out = {}, used = {}, rest = [];
        const saved = slots;
        for (const it of items) {
            const s = saved[it.name];
            if (s && s[0] < cols && s[1] < rows && !used[s]) { out[it.name] = s; used[s] = true; }
            else rest.push(it);
        }
        let c = 0, r = 0;
        for (const it of rest) {
            while (used[[c, r]] && c < cols)
                if (++r >= rows) { r = 0; c++; }
            out[it.name] = [c, r];
            used[[c, r]] = true;
        }
        return out;
    }
    function cellAt(px, py) {
        return [Math.max(0, Math.min(cols - 1, Math.floor((px - 4) / pitchX))),
                Math.max(0, Math.min(rows - 1, Math.floor((py - 4) / pitchY)))];
    }
    function itemAt(c, r, skip) {
        return items.find(i => !skip[i.name] && placed[i.name]?.[0] === c && placed[i.name]?.[1] === r) ?? null;
    }
    function dragTo(it, dx, dy) {
        dragging = true;
        dragDx = dx;
        dragDy = dy;
        const p = placed[it.name];
        const t = cellAt(4 + p[0] * pitchX + dx + pitchX / 2, 4 + p[1] * pitchY + dy + 30);
        dropOn = itemAt(t[0], t[1], sel)?.name ?? "";
    }
    function drop(it) {
        const p = placed[it.name];
        const t = cellAt(4 + p[0] * pitchX + dragDx + pitchX / 2, 4 + p[1] * pitchY + dragDy + 30);
        dragging = false;
        dragDx = dragDy = 0;
        dropOn = "";
        dropped = true;

        const moving = selected().length ? selected() : [it];
        const paths = moving.filter(i => i.kind === "file").map(i => i.path);
        const target = itemAt(t[0], t[1], sel);
        if (target?.kind === "trash") return remove(moving);
        if (target?.kind === "file" && target.dir) {
            if (paths.length) Apps.run(["mv", "-n", "--"].concat(paths, [target.path]));
            return;
        }

        const dc = t[0] - p[0], dr = t[1] - p[1];
        if (!dc && !dr) return;
        const next = Object.assign({}, placed);    // freeze the auto layout too
        const used = {};
        for (const n in next)
            if (!sel[n] && n !== it.name) used[next[n]] = true;
        for (const m of moving) {
            let c = Math.max(0, Math.min(cols - 1, placed[m.name][0] + dc));
            let r = Math.max(0, Math.min(rows - 1, placed[m.name][1] + dr));
            for (let n = cols * rows; used[[c, r]] && n > 0; n--)
                if (++r >= rows) { r = 0; c = (c + 1) % cols; }
            next[m.name] = [c, r];
            used[[c, r]] = true;
        }
        saveSlots(next);
    }

    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell:desktop"
    // focus only when clicked, like the real desktop: arrows aside, Del/F2/Enter work
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Component.onCompleted: Apps.run(["mkdir", "-p", dir])

    FolderListModel {
        id: files
        folder: "file://" + desk.dir
        showDirsFirst: true
        showDotAndDotDot: false
        sortCaseSensitive: false
        onCountChanged: Qt.callLater(desk.rebuild)
        onStatusChanged: Qt.callLater(desk.rebuild)
        onDataChanged: Qt.callLater(desk.rebuild)
    }
    FolderListModel {
        id: trash
        folder: "file://" + Ui.home + "/.local/share/Trash/files"
        showHidden: true
        showDotAndDotDot: false
    }
    readonly property bool trashFull: trash.count > 0
    onTrashFullChanged: rebuild()

    function rebuild() {
        const l = [
            { kind: "pc",    name: "This PC",     icon: "computer" },
            { kind: "trash", name: "Recycle Bin", icon: trashFull ? "user-trash-full" : "user-trash" },
        ];
        for (let i = 0; i < files.count; i++)
            l.push({
                kind  : "file",
                name  : files.get(i, "fileName"),
                path  : files.get(i, "filePath"),
                dir   : files.get(i, "fileIsDir"),
                suffix: (files.get(i, "fileSuffix") || "").toLowerCase(),
            });
        items = l;
        if (pending && l.some(i => i.name === pending)) {
            sel = { [pending]: true };
            renaming = pending;
            pending = "";
        }
    }

    readonly property var images: ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "avif"]
    readonly property var videos: ["mp4", "mkv", "webm", "mov", "avi", "m4v", "wmv", "flv", "ts"]
    readonly property var mime: ({
        txt: "text-x-generic", md: "text-x-generic", log: "text-x-generic", conf: "text-x-generic",
        pdf: "application-pdf", html: "text-html",
        sh: "text-x-script", py: "text-x-script", lua: "text-x-script",
        zip: "package-x-generic", tar: "package-x-generic", gz: "package-x-generic",
        xz: "package-x-generic", zst: "package-x-generic", "7z": "package-x-generic", rar: "package-x-generic",
        mp3: "audio-x-generic", flac: "audio-x-generic", ogg: "audio-x-generic", opus: "audio-x-generic", wav: "audio-x-generic",
        mp4: "video-x-generic", mkv: "video-x-generic", webm: "video-x-generic", mov: "video-x-generic", avi: "video-x-generic",
        iso: "media-optical", exe: "application-x-ms-dos-executable", appimage: "application-x-executable",
    })
    function iconOf(it) {
        if (it.kind !== "file") return it.icon;
        if (it.dir) return "folder";
        return mime[it.suffix] ?? "text-x-generic";
    }

    function selected() { return items.filter(i => sel[i.name]); }
    function open(it) {
        if (it.kind === "pc")    return Apps.launch([Apps.explorer, "computer:///"]);
        if (it.kind === "trash") return Apps.launch([Apps.explorer, "trash:///"]);
        if (it.suffix === "desktop" && games[it.name])
            return Apps.launchGame(["gio", "launch", it.path]);
        Apps.openPath(it.path, it.dir, it.suffix);
    }
    function remove(list) {
        const p = list.filter(i => i.kind === "file").map(i => i.path);
        if (p.length) Apps.run(["gio", "trash", "--"].concat(p));
    }
    function unique(base, ext) {
        const names = new Set(items.map(i => i.name));
        let n = base + ext;
        for (let k = 2; names.has(n); k++)
            n = `${base} (${k})${ext}`;
        return n;
    }
    function create(folder) {
        const n = unique(folder ? "New folder" : "New Text Document", folder ? "" : ".txt");
        pending = n;
        Apps.run(folder ? ["mkdir", "--", dir + "/" + n] : ["touch", "--", dir + "/" + n]);
    }
    function commitRename(it, name) {
        renaming = "";
        name = name.trim();
        if (!name || name === it.name || name.includes("/")) return;
        sel = { [name]: true };
        if (slots[it.name]) {
            const s = Object.assign({}, slots);
            s[name] = s[it.name];
            delete s[it.name];
            saveSlots(s);
        }
        Apps.run(["mv", "-n", "--", it.path, dir + "/" + name]);
    }

    function itemMenu(it) {
        if (it.kind === "pc")
            return [{ label: "Open", act: () => open(it) }];
        if (it.kind === "trash")
            return [
                { label: "Open", act: () => open(it) },
                { label: "Empty Recycle Bin", enabled: trashFull, act: () => Apps.run(["gio", "trash", "--empty"]) },
            ];
        const s = selected().filter(i => i.kind === "file");
        const l = [{ label: "Open", act: () => s.forEach(open) }];
        if (it.dir && s.length === 1)
            l.push({ label: "Open in Terminal", act: () => Apps.launch([Apps.terminal, "--working-directory=" + it.path]) });
        l.push({ sep: true });
        l.push({ label: "Copy as path", act: () => Quickshell.clipboardText = s.map(i => `"${i.path}"`).join(" ") });
        l.push({ sep: true });
        l.push({ label: "Delete", act: () => remove(s) });
        l.push({ label: "Rename", enabled: s.length === 1, act: () => renaming = it.name });
        return l;
    }
    function deskMenu() {
        return [
            { label: "Refresh", act: () => { files.folder = ""; files.folder = "file://" + dir; } },
            { label: "Sort by name", act: () => saveSlots({}) },
            { sep: true },
            { label: "New folder",        icon: "folder",         act: () => create(true) },
            { label: "New Text Document", icon: "text-x-generic", act: () => create(false) },
            { sep: true },
            { label: "Open in Terminal",      act: () => Apps.launch([Apps.terminal, "--working-directory=" + dir]) },
            { label: "Open in File Explorer", act: () => Apps.launch([Apps.explorer, dir]) },
            { sep: true },
            { label: "Personalize", act: () => Apps.run(["quickshell", "-c", "hyprquickpaper"]) },
        ];
    }

    ContextMenu { id: menu }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: ev => {
            const s = desk.selected();
            if (desk.renaming) return;
            if (ev.key === Qt.Key_Delete)                                   desk.remove(s);
            else if (ev.key === Qt.Key_F2 && s.length === 1)                desk.renaming = s[0].kind === "file" ? s[0].name : "";
            else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter)   s.forEach(desk.open);
            else if (ev.key === Qt.Key_F5)                                  desk.rebuild();
            else if (ev.key === Qt.Key_Escape)                              desk.sel = {};
            else if (ev.key === Qt.Key_A && (ev.modifiers & Qt.ControlModifier)) {
                const all = {};
                for (const i of desk.items) all[i.name] = true;
                desk.sel = all;
            } else return;
            ev.accepted = true;
        }

        // empty space: deselect, rubber band, desktop menu
        MouseArea {
            id: bg
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property point o

            onPressed: m => {
                keys.forceActiveFocus();
                menu.visible = false;
                if (!(m.modifiers & Qt.ControlModifier)) desk.sel = {};
                o = Qt.point(m.x, m.y);
            }
            onPositionChanged: m => {
                if (!(pressedButtons & Qt.LeftButton)) return;
                band.x = Math.min(o.x, m.x);  band.y = Math.min(o.y, m.y);
                band.width = Math.abs(m.x - o.x);  band.height = Math.abs(m.y - o.y);
                band.visible = band.width > 3 || band.height > 3;
                const s = {};
                for (let i = 0; i < cells.count; i++) {
                    const c = cells.itemAt(i);
                    if (!c) continue;
                    const p = c.mapToItem(bg, 0, 0);
                    if (p.x < band.x + band.width && p.x + c.width > band.x
                        && p.y < band.y + band.height && p.y + c.height > band.y)
                        s[c.modelData.name] = true;
                }
                desk.sel = s;
            }
            onReleased: band.visible = false
            onClicked: m => { if (m.button === Qt.RightButton) menu.popup(bg, m.x, m.y, desk.deskMenu()); }
        }

        Item {
            id: grid
            anchors.fill: parent

            Repeater {
                id: cells
                model: desk.items

                delegate: Item {
                    id: cell
                    required property var modelData
                    readonly property bool selected: !!desk.sel[modelData.name]
                    readonly property bool editing : desk.renaming !== "" && desk.renaming === modelData.name
                    property var meta: null    // Name/Icon from a .desktop file
                    readonly property var  pos  : desk.placed[modelData.name] ?? [0, 0]
                    readonly property bool moved: desk.dragging && selected

                    x: 4 + pos[0] * desk.pitchX + (moved ? desk.dragDx : 0)
                    y: 4 + pos[1] * desk.pitchY + (moved ? desk.dragDy : 0)
                    width: 76
                    height: 92
                    z: moved ? 3 : selected || editing ? 2 : 1
                    opacity: moved ? 0.7 : 1

                    FileView {
                        path: cell.modelData.suffix === "desktop" ? cell.modelData.path : ""
                        onLoaded: {
                            const t = text();
                            const get = k => (new RegExp(`^${k}=(.*)$`, "m").exec(t) ?? [])[1];
                            cell.meta = { name: get("Name"), icon: get("Icon") };
                            if (/^Exec=.*steam:\/\/rungameid|^Categories=.*\bGame\b/m.test(t))
                                desk.games[cell.modelData.name] = true;
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Math.max(parent.height - 2, label.y + label.height + 4)
                        color: cell.selected || desk.dropOn === cell.modelData.name ? Theme.deskSel
                             : ma.containsMouse ? Theme.deskHover : "transparent"
                        border.color: cell.selected ? Theme.deskSelBorder : "transparent"
                    }

                    Item {
                        id: art
                        x: 14; y: 4
                        width: 48; height: 48

                        readonly property bool isImage: desk.images.includes(cell.modelData.suffix)
                        readonly property bool isVideo: desk.videos.includes(cell.modelData.suffix)
                        readonly property string thumb: isVideo
                            ? Ui.home + "/.cache/thumbnails/large/" + Qt.md5("file://" + encodeURI(cell.modelData.path)) + ".png"
                            : ""

                        Image {
                            id: pic
                            visible: status === Image.Ready
                            anchors.fill: parent
                            source: art.isImage ? "file://" + cell.modelData.path
                                  : art.isVideo ? "file://" + art.thumb : ""
                            sourceSize: Qt.size(96, 96)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                            onStatusChanged: if (status === Image.Error && art.isVideo && !makeThumb.tried) {
                                makeThumb.tried = true;
                                makeThumb.running = true;
                            }
                        }
                        Process {
                            id: makeThumb
                            property bool tried: false
                            command: ["sh", "-c", 'mkdir -p "${2%/*}" && ffmpegthumbnailer -i "$1" -o "$2.part.png" -s 256 && mv "$2.part.png" "$2"',
                                      "sh", cell.modelData.path, art.thumb]
                            onExited: code => { if (code === 0) { pic.source = ""; pic.source = "file://" + art.thumb; } }
                        }
                        IconImage {
                            visible: pic.status !== Image.Ready
                            anchors.fill: parent
                            source: Apps.icon(cell.meta?.icon || desk.iconOf(cell.modelData))
                        }
                        Rectangle {
                            visible: cell.modelData.suffix === "desktop"
                            anchors { left: parent.left; bottom: parent.bottom }
                            width: 14; height: 14
                            color: "#ffffff"
                            Text { anchors.centerIn: parent; text: "↗"; color: "#0063b1"; font.pixelSize: 12; font.bold: true }
                        }
                    }

                    Text {
                        id: label
                        visible: !cell.editing
                        x: 2; y: 56
                        width: parent.width - 4
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: cell.selected ? 8 : 2
                        elide: Text.ElideRight
                        text: cell.meta?.name || cell.modelData.name
                        color: "#ffffff"
                        font.family: Theme.font
                        font.pixelSize: Theme.textSize
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#d0000000"
                            shadowBlur: 0.25
                            shadowHorizontalOffset: 1
                            shadowVerticalOffset: 1
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        property point o    // press point, in grid coordinates

                        onPressed: m => {
                            desk.dropped = false;
                            menu.visible = false;
                            o = ma.mapToItem(grid, m.x, m.y);
                            keys.forceActiveFocus();
                            const n = cell.modelData.name;
                            if (m.modifiers & Qt.ControlModifier) {
                                const s = Object.assign({}, desk.sel);
                                if (s[n]) delete s[n]; else s[n] = true;
                                desk.sel = s;
                            } else if (!cell.selected) {
                                desk.sel = { [n]: true };
                            }
                        }
                        onPositionChanged: m => {
                            if (!(pressedButtons & Qt.LeftButton) || cell.editing) return;
                            const g = ma.mapToItem(grid, m.x, m.y);
                            if (!desk.dragging && Math.hypot(g.x - o.x, g.y - o.y) < 6) return;
                            if (!cell.selected) desk.sel = { [cell.modelData.name]: true };
                            desk.dragTo(cell.modelData, g.x - o.x, g.y - o.y);
                        }
                        onReleased: if (desk.dragging) desk.drop(cell.modelData)
                        onDoubleClicked: desk.open(cell.modelData)
                        onClicked: m => {
                            if (desk.dropped) return;
                            if (m.button === Qt.RightButton)
                                menu.popup(ma, m.x, m.y, desk.itemMenu(cell.modelData));
                            else if (!(m.modifiers & Qt.ControlModifier))
                                desk.sel = { [cell.modelData.name]: true };
                        }
                    }

                    Rectangle {
                        visible: cell.editing
                        x: -12; y: 56
                        width: parent.width + 24
                        height: field.contentHeight + 6
                        color: "#ffffff"
                        border.color: "#000000"

                        TextInput {
                            id: field
                            anchors { fill: parent; margins: 3 }
                            horizontalAlignment: TextInput.AlignHCenter
                            wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                            color: "#000000"
                            selectionColor: Theme.accent
                            selectedTextColor: "#ffffff"
                            font.family: Theme.font
                            font.pixelSize: Theme.textSize
                            onActiveFocusChanged: if (!activeFocus && cell.editing) desk.commitRename(cell.modelData, text)
                            Keys.onReturnPressed: desk.commitRename(cell.modelData, text)
                            Keys.onEnterPressed:  desk.commitRename(cell.modelData, text)
                            Keys.onEscapePressed: desk.renaming = ""
                        }
                    }
                    onEditingChanged: if (editing) {
                        field.text = modelData.name;
                        const dot = modelData.dir ? -1 : modelData.name.lastIndexOf(".");
                        field.select(0, dot > 0 ? dot : modelData.name.length);
                        field.forceActiveFocus();
                    }
                }
            }
        }

        Rectangle {
            id: band
            visible: false
            color: Qt.rgba(0, 0.47, 0.84, 0.25)
            border.color: Theme.accent
        }
    }
}
