{ config, ... }:
{
    flake.modules.nixos.profile-laptop = {
        imports = with config.flake.modules.nixos; [
            core cli
            auth gpg pass sops
            boot boot-silent
            network ssh
            git neovim nh
            atuin
        ];
    };
}
