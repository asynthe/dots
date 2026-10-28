import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

PopupWindow {
    id: m

    property var  items: []
    property bool up   : false
    property bool grab : true    // false when the parent window's grab covers it

    anchor.adjustment: PopupAdjustment.All
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: up ? (Edges.Top | Edges.Right) : (Edges.Bottom | Edges.Right)

    color: "transparent"
    visible: false
    implicitWidth: Math.max(220, widest + 76)
    implicitHeight: col.implicitHeight + 10

    readonly property real widest: {
        let w = 0;
        for (const it of items)
            if (!it.sep) w = Math.max(w, fm.advanceWidth(it.label));
        return w;
    }
    FontMetrics { id: fm; font.family: Theme.font; font.pixelSize: Theme.textSize }

    function popup(item, x, y, list, upward) {
        visible = false;
        anchor.item = item;
        anchor.rect.x = x;
        anchor.rect.y = y;
        up = !!upward;
        items = list;
        visible = true;
    }

    HyprlandFocusGrab { active: m.visible && m.grab; windows: [m]; onCleared: m.visible = false }

    Rectangle {
        anchors.fill: parent
        color: Theme.menuBg
        border.color: Theme.menuBorder

        Item { focus: true; Keys.onEscapePressed: m.visible = false }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1; topMargin: 5 }

            Repeater {
                model: m.items

                delegate: Item {
                    id: row
                    required property var modelData
                    readonly property bool on: modelData.enabled !== false

                    width: col.width
                    height: modelData.sep ? 9 : 32

                    Rectangle {
                        visible: row.modelData.sep === true
                        anchors.centerIn: parent
                        width: parent.width - 2
                        height: 1
                        color: Theme.menuSep
                    }
                    MouseArea {
                        id: ma
                        visible: !row.modelData.sep
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: row.on
                        onClicked: { m.visible = false; row.modelData.act?.(); }

                        Rectangle { anchors.fill: parent; color: ma.containsMouse ? Theme.menuHover : "transparent" }
                        IconImage {
                            visible: !!row.modelData.icon
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 16
                            source: row.modelData.icon ? Apps.icon(row.modelData.icon) : ""
                        }
                        Label {
                            x: 40
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.label ?? ""
                            color: row.on ? Theme.fg : "#6d6d6d"
                        }
                    }
                }
            }
        }
    }
}
