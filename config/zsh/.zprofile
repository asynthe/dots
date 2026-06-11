if uwsm check may-start; then
    exec uwsm start hyprland-uwsm.desktop
    systemctl --user enable --now hyprpolkitagent.service
fi
