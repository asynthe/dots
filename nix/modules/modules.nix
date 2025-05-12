{
    imports = [

        # ─────────────── Testing ───────────────
        #./testing/acpi.nix # TODO What is this for?
        #./testing/avahi.nix # TODO FIX: Always tested but doesn't work.
        #./testing/greetd.nix # TODO FIX
        #./testing/printer.nix # TODO FIX: SANE and other stuff.
        #./testing/httpd.nix
        #./simple/clamav.nix
        #./simple/kmscon.nix
        #./simple/mirakurun.nix
        #./simple/monica.nix
        #./simple/ollama.nix

        # ─────────────── Simple ───────────────
        ./simple/fcitx5.nix
        ./simple/gpg.nix
        ./simple/hyprland.nix
        ./simple/neovim.nix
    ];
}
