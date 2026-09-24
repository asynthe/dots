{ ... }:
{
    flake.modules.darwin.homebrew = { ... }: {
        homebrew = {
            enable = true;
            onActivation = {
                autoUpdate = true;
                upgrade = true;
                # "zap" uninstalls anything installed but unlisted below --
                # switch to it once taps/brews/casks actually reflect reality.
                cleanup = "none";
            };

            taps  = [ ];
            brews = [ ];
            casks = [
                "claude-code"
                "firefox"
                "ghostty"
                "mullvad-vpn"
                "tailscale-app" # same tailnet as p1 -- log in once via the app, GUI-managed like on iOS/Android
                "ungoogled-chromium"
                "vscodium"
            ];
        };
    };
}
