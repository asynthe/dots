//@ pragma UseQApplication
//@ pragma IconTheme Fluent-dark

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool hidden: false

    // Icons go on one screen: the external monitor
    // when one is plugged in, the laptop panel otherwise. Follows hotplug.
    readonly property var main: {
        const s = Quickshell.screens;
        return s.find(x => !/^(eDP|LVDS|DSI)/i.test(x.name)) ?? s[0] ?? null;
    }

    Variants {
        model: root.hidden || !root.main ? [] : [root.main]
        Desktop {}
    }

    IpcHandler {
        target: "desktop"
        function toggle(): void { root.hidden = !root.hidden; }
    }
}
