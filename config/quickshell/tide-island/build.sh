#!/usr/bin/env bash
set -euo pipefail

REPO="${TIDE_REPO:-https://github.com/enhaoswen/Tide-island}"
REF="${TIDE_REF:-2b91fbd0f8f605f71a9daf3b5bcc11482c95c4f3}"
SRC="${TIDE_SRC:-${XDG_CACHE_HOME:-$HOME/.cache}/tide-island-src}"
PREFIX="${TIDE_PREFIX:-$HOME/.local}"

if [[ -d "$SRC/.git" ]]; then
    git -C "$SRC" fetch --depth 1 origin "$REF"
    git -C "$SRC" checkout --force FETCH_HEAD
else
    git clone "$REPO" "$SRC"
    git -C "$SRC" checkout --force "$REF"
fi

# /bin/bash does not exist on NixOS; /usr/bin/quickshell exists on no distro
# that installs quickshell outside /usr. Both stay portable after patching.
sed -i '1s|.*|#!/usr/bin/env bash|' "$SRC/tide-island-launcher"
if ! grep -q 'QUICKSHELL_BIN=' "$SRC/tide-island-launcher"; then
    sed -i 's|/usr/bin/quickshell|"$QUICKSHELL_BIN"|g' "$SRC/tide-island-launcher"
    sed -i '/^SERVICE_NAME=/a QUICKSHELL_BIN="${QUICKSHELL_BIN:-$(command -v quickshell)}"' "$SRC/tide-island-launcher"
    sed -i 's|-f ""\$QUICKSHELL_BIN" |-f "$QUICKSHELL_BIN |' "$SRC/tide-island-launcher"
fi
# The shell resolves tide-island-config-app off PATH, and a systemd user
# session does not necessarily carry $PREFIX/bin. See docs/TIDE.md.
if ! grep -q 'INSTALL_PREFIX/bin:\$PATH' "$SRC/tide-island-launcher"; then
    sed -i '/^SERVICE_NAME=/i export PATH="$INSTALL_PREFIX/bin:$PATH"' "$SRC/tide-island-launcher"
fi

# Auto-hide masks the layer down to a 260x10 box at the top centre, which a
# trackpad cannot reliably hit. Widen the reveal band to the full screen.
# See docs/TIDE.md.
sed -i 's|^\( *readonly property real autoHideRevealWidth:\).*|\1 root.width|' \
    "$SRC/DynamicIslandWindow.qml"

bash -n "$SRC/tide-island-launcher"

# The config app bakes /usr paths into the shortcuts it writes to hyprland.lua.
# These are constexpr, not CMake-substituted, so they need rewriting to $PREFIX.
sed -i \
    -e "s|/usr/bin/quickshell|quickshell|g" \
    -e "s|/usr/share/tide-island|$PREFIX/share/tide-island|g" \
    "$SRC/Tide-island-app/backend.cpp"

build() {
    # build.ninja and CMakeCache.txt bake absolute toolchain paths. On NixOS a
    # GC collects them and every later run dies on a missing store path.
    # Reconfiguring from scratch is the only way back.
    if [[ -d "$SRC/build" ]] && grep -rhoE '/nix/store/[a-z0-9]{32}-[^/"'"'"' :]+' \
            "$SRC/build/build.ninja" "$SRC/build/CMakeCache.txt" 2>/dev/null \
            | sort -u | while read -r sp; do [[ -e "$sp" ]] || { echo stale; break; }; done \
            | grep -q stale; then
        echo "build.sh: stale store paths in build cache, reconfiguring" >&2
        rm -rf "$SRC/build"
    fi
    cmake -S "$SRC" -B "$SRC/build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
    ninja -C "$SRC/build"
    ninja -C "$SRC/build" install
}

# The shipped unit hardcodes /usr/bin/tide-island and installs to
# ~/.local/lib/systemd/user, which systemd does not search.
write_unit() {
    local dir="$HOME/.config/systemd/user"
    mkdir -p "$dir"
    {
        echo "[Unit]"
        echo "Description=Tide Island Dynamic Island"
        echo "After=graphical-session.target"
        echo "PartOf=graphical-session.target"
        echo
        echo "[Service]"
        echo "Type=simple"
        [[ -n "${TIDE_QT5COMPAT_QML:-}" ]] && \
            echo "Environment=QML2_IMPORT_PATH=$TIDE_QT5COMPAT_QML"
        # The pin toggle's marker outlives a restart otherwise, and the
        # keybind would then be inverted. /usr/bin/env is the one absolute
        # path NixOS does provide.
        echo "ExecStartPre=-/usr/bin/env rm -f %t/tide-pinned"
        echo "ExecStart=$PREFIX/bin/tide-island"
        echo "Restart=on-failure"
        echo "RestartSec=3"
        echo
        echo "[Install]"
        echo "WantedBy=graphical-session.target"
    } > "$dir/tide-island.service"
    systemctl --user daemon-reload 2>/dev/null || true
}

if [[ -e /etc/NIXOS ]]; then
    exec nix-shell "$(dirname "$(readlink -f "$0")")/shell.nix" \
        --run "$(declare -f build write_unit); SRC='$SRC'; PREFIX='$PREFIX'; build && write_unit"
else
    build
    write_unit
fi
