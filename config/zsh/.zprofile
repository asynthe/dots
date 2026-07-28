# Hand off to Hyprland on tty1. No `exec`: quitting the compositor returns
# here, dropping to this shell instead of logging out.
#
# Pass hyprland.desktop, not hyprland-uwsm.desktop -- the latter's Exec is
# itself `uwsm start ... hyprland.desktop`, so uwsm would end up wrapping uwsm.
if uwsm check may-start &>/dev/null; then
    uwsm start -e -D Hyprland hyprland.desktop
fi
