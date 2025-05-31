{ lib, ... }: {
    nix.settings = {
        substituters = lib.mkBefore [
            "https://cache.nixos.org"
            "https://yazi.cachix.org"
            "https://wezterm.cachix.org" 
        ];
        trusted-public-keys = lib.mkBefore [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
            "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
    };
}
