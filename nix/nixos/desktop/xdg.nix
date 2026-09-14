# XDG base directories and the per-app redirects that keep $HOME flat.
# See docs/HOME_STRUCTURE.md for the layout these dirs belong to.
#
# Two halves:
#   user-dirs.defaults  the visible folders (~/downloads, ~/desktop)
#   sessionVariables    where apps that ignore XDG get sent instead
#
# An app only lands here if it honours an env var. Everything that hardcodes
# a dotfile (steam, factorio, mixxx, stepmania, vscode) stays where it is —
# `xdg-ninja` lists them, most are upstream bugs, not config gaps.
{
    flake.modules.nixos.xdg = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            xdg-ninja
            xdg-user-dirs
        ];

        # xdg-user-dirs reads this on login and writes ~/.config/user-dirs.dirs.
        # Lowercase, and only the two folders that actually exist — the rest
        # point at $HOME so nothing gets auto-created.
        environment.etc."xdg/user-dirs.defaults".text = ''
            DOWNLOAD=downloads
            DESKTOP=desktop
            DOCUMENTS=
            MUSIC=
            PICTURES=
            VIDEOS=
            TEMPLATES=
            PUBLICSHARE=
        '';

        environment.sessionVariables = {
            # Base dirs. These are the spec defaults, but setting them
            # explicitly means the redirects below can reference them.
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME   = "$HOME/.local/share";
            XDG_STATE_HOME  = "$HOME/.local/state";
            XDG_CACHE_HOME  = "$HOME/.cache";

            # ─────────────── Dev toolchains ───────────────
            CARGO_HOME             = "$HOME/.local/share/cargo";
            RUSTUP_HOME            = "$HOME/.local/share/rustup";
            GRADLE_USER_HOME       = "$HOME/.local/share/gradle";
            NPM_CONFIG_USERCONFIG  = "$HOME/.config/npm/npmrc";
            NPM_CONFIG_CACHE       = "$HOME/.cache/npm";
            NODE_REPL_HISTORY      = "$HOME/.local/state/node_repl_history";
            YARN_ENABLE_GLOBAL_CACHE = "true";
            PYTHONPYCACHEPREFIX    = "$HOME/.cache/python";
            PYTHONUSERBASE         = "$HOME/.local";
            DOCKER_CONFIG          = "$HOME/.config/docker";
            KUBECONFIG             = "$HOME/.config/kube/config";
            KUBECACHEDIR           = "$HOME/.cache/kube";

            # ─────────────── Android / RN ───────────────
            ANDROID_HOME           = "$HOME/.local/share/android/sdk";
            ANDROID_USER_HOME      = "$HOME/.local/share/android";
            _JAVA_OPTIONS          = "-Djava.util.prefs.userRoot=$HOME/.config/java";

            # ─────────────── Wine ───────────────
            # ~/wine/prefix/<app> is the layout; this is only the fallback for
            # bare `wine foo.exe` with no prefix set. See docs/WINE.md.
            WINEPREFIX             = "$HOME/wine/prefix/default";

            # ─────────────── Shell / misc ───────────────
            GNUPGHOME              = "$HOME/git/auth/gpg";
            PASSWORD_STORE_DIR     = "$HOME/git/auth/pass";
            SOPS_AGE_KEY_FILE      = "$HOME/git/auth/age/keys.txt";
            LESSHISTFILE           = "$HOME/.local/state/less_history";
            WGETRC                 = "$HOME/.config/wgetrc";
            XCOMPOSECACHE          = "$HOME/.cache/X11/xcompose";
            __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/nv";
            PULSE_COOKIE           = "$HOME/.cache/pulse/cookie";
        };
    };
}
