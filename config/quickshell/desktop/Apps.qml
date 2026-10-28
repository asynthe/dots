pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: apps

    readonly property string explorer: Quickshell.shellPath("explorer.sh")
    readonly property string terminal: "ghostty"

    function icon(name) {
        return Quickshell.iconPath(name || "application-x-executable", "application-x-executable");
    }

    function run(cmd) { Quickshell.execDetached(cmd); }

    // Whatever opens from the desktop starts floating. gio
    // hands files to the app and exits, so Hyprland can't tie the window to
    // the launch; instead hyprland.lua's DesktopLaunchFloat rule (float, sized,
    // centered) is on from just before a launch until the next window opens,
    // or 8s pass for a file that lands in an existing window.
    property int expect: 0

    function rule(name, on) { run(["hyprctl", "eval", `${name}:set_enabled(${on})`]); }
    function withRule(name, cmd) {
        // the rule must be on before the window maps, so the eval goes first
        run(["sh", "-c", `hyprctl eval "${name}:set_enabled(true)" >/dev/null; exec "$@"`, "sh"].concat(cmd));
    }
    function launch(cmd) {
        expect++;
        floatOff.restart();
        withRule("DesktopLaunchFloat", cmd);
    }
    // Games aren't floated; DesktopLaunchGame only drops their fade. A game can
    // take a while (Steam starting it), so that rule just stays on for 30s.
    function launchGame(cmd) {
        gameOff.restart();
        withRule("DesktopLaunchGame", cmd);
    }
    Timer { id: gameOff; interval: 30000; onTriggered: apps.rule("DesktopLaunchGame", false) }
    Timer {
        id: floatOff
        interval: 8000
        onTriggered: { apps.expect = 0; apps.rule("DesktopLaunchFloat", false); }
    }
    function openPath(path, isDir, suffix) {
        if (isDir)                     launch([explorer, path]);
        else if (suffix === "desktop") launch(["gio", "launch", path]);
        else                           launch(["gio", "open", path]);
    }

    Connections {
        target: Hyprland
        function onRawEvent(ev) {
            if (ev.name !== "openwindow" || apps.expect <= 0)
                return;
            if (--apps.expect === 0) {
                floatOff.stop();
                apps.rule("DesktopLaunchFloat", false);
            }
        }
    }
}
