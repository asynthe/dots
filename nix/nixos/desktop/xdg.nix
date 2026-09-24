{
    flake.modules.nixos.xdg = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            xdg-ninja
            xdg-user-dirs
        ];

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
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME   = "$HOME/.local/share";
            XDG_STATE_HOME  = "$HOME/.local/state";
            XDG_CACHE_HOME  = "$HOME/.cache";

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

            ANDROID_HOME           = "$HOME/.local/share/android/sdk";
            ANDROID_USER_HOME      = "$HOME/.local/share/android";
            _JAVA_OPTIONS          = "-Djava.util.prefs.userRoot=$HOME/.config/java";

            WINEPREFIX             = "$HOME/wine/prefix/default";

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
