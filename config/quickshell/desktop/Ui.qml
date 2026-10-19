pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: s

    readonly property string home: Quickshell.env("HOME")

    FileView {
        id: userDirs
        path: (Quickshell.env("XDG_CONFIG_HOME") || s.home + "/.config") + "/user-dirs.dirs"
        blockLoading: true
    }
    function dir(name) {
        const m = new RegExp(`^XDG_${name}_DIR="([^"]*)"`, "m").exec(userDirs.text());
        if (m) return m[1].replace("$HOME", home);
        const def = { DESKTOP: "Desktop", DOCUMENTS: "Documents", PICTURES: "Pictures", DOWNLOAD: "Downloads" };
        return home + "/" + (def[name] ?? "");
    }
}
