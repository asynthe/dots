#!/usr/bin/env bash
# Windows 11 look for the desktop icons (qs -c desktop) and Nemo as File Explorer.
#   GTK:   vinceliuice/Fluent-gtk-theme  -> ~/.local/share/themes (Fluent-Dark, patched to OLED black)
#   icons: vinceliuice/Fluent-icon-theme -> ~/.local/share/icons  (Fluent-dark)
# Re-run to update.
set -euo pipefail

themes=${XDG_DATA_HOME:-$HOME/.local/share}/themes
icons=${XDG_DATA_HOME:-$HOME/.local/share}/icons
cache=${XDG_CACHE_HOME:-$HOME/.cache}
mkdir -p "$themes" "$icons"

fetch() {   # repo dest
    if [ -d "$2/.git" ]; then
        git -C "$2" pull --ff-only -q
    else
        rm -rf "$2"
        git clone -q --depth 1 "https://github.com/$1" "$2"
    fi
}

# both repos build their variants with their own install.sh (GTK one needs sassc)
fetch vinceliuice/Fluent-icon-theme "$cache/fluent-icon-theme"
(cd "$cache/fluent-icon-theme" && ./install.sh -d "$icons" >/dev/null)

# OLED: Fluent's dark greys -> real black (menus/popovers a hair lighter so they
# still read as raised). A tweak makes install.sh compile the patched sass
# instead of copying its prebuilt css; solid also drops the translucency.
gtk=$cache/fluent-gtk-theme
[ -d "$gtk/.git" ] && git -C "$gtk" checkout -q -- .    # undo the last patch so pull works
fetch vinceliuice/Fluent-gtk-theme "$gtk"
sed -i -e 's/#333333/#000000/g' -e 's/#2B2B2B/#000000/g' -e 's/#303030/#0A0A0A/g' \
       -e 's/#3C3C3C/#141414/g' -e 's/#1F1F1F/#000000/g' \
       -e "/variant == 'dark'/ s/return #202020;/return #000000;/" \
       -e "/variant == 'dark'/ s/return #2C2C2C;/return #000000;/" \
       "$gtk/src/_sass/_colors.scss"
(cd "$gtk" && ./install.sh -d "$themes" -c dark --tweaks solid >/dev/null)

gsettings set org.gnome.desktop.interface icon-theme Fluent-dark   # config/gtk-*/settings.ini agree

# Nemo: icon view everywhere (per-folder views ignored), thumbnails for big files
# too (the default 1 MB limit skips nearly every video), no desktop drawing
# since quickshell owns the desktop.
gsettings set org.nemo.preferences default-folder-viewer 'icon-view'
gsettings set org.nemo.preferences ignore-view-metadata true
gsettings set org.nemo.preferences thumbnail-limit 34359738368   # 32 GiB
gsettings set org.nemo.preferences show-location-entry true
gsettings set org.nemo.desktop show-desktop-icons false 2>/dev/null || true
gsettings set org.nemo.window-state start-with-sidebar true
gsettings set org.nemo.window-state start-with-toolbar true

# "File Explorer" entry, the default for folders.
apps=${XDG_DATA_HOME:-$HOME/.local/share}/applications
mkdir -p "$apps"
cat >"$apps/file-explorer.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=File Explorer
Icon=system-file-manager
Exec=$HOME/.config/quickshell/desktop/explorer.sh %U
MimeType=inode/directory;
StartupWMClass=nemo
Categories=System;FileManager;
DESKTOP

# Codium as the opener for files: each file gets its own window instead of a
# tab in whatever window is already open. Hidden from menus.
cat >"$apps/codium-window.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=VSCodium (new window)
Icon=vscodium
Exec=/usr/bin/vscodium --ozone-platform-hint=auto --new-window %F
StartupWMClass=VSCodium
NoDisplay=true
DESKTOP

# Default apps: video in mpv, audio in Celluloid, text/code in Codium, folders in Explorer.
for m in video/mp4 video/x-matroska video/webm video/quicktime video/x-msvideo video/mpeg video/ogg; do
    xdg-mime default mpv.desktop "$m"
done
for m in audio/mpeg audio/flac audio/ogg audio/x-opus+ogg audio/x-wav audio/mp4 audio/aac; do
    xdg-mime default io.github.celluloid_player.Celluloid.desktop "$m"
done
for m in text/plain text/markdown text/x-shellscript text/x-python application/x-shellscript \
         application/json application/xml text/x-csrc text/x-c++src text/css application/toml; do
    xdg-mime default codium-window.desktop "$m"
done
xdg-mime default file-explorer.desktop inode/directory

echo "installed: $themes/Fluent-Dark, $icons/Fluent-dark"
