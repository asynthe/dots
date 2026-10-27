{ ... }:
{
    # Copilot key arrives as a one-report LEFTMETA+F23 chord that Hyprland's
    # bind matcher never catches. keyd turns it into a lone F13 (the [meta]
    # layer drops meta for the remapped key), which hyprland.lua binds.
    # keyd's NixOS unit is too sandboxed for command() into ~ like on Gentoo.
    flake.modules.nixos.copilot-key = { ... }: {
        services.keyd = {
            enable = true;
            keyboards.copilot = {
                ids = [ "*" ];
                settings = {
                    main.f23 = "f13";
                    meta.f23 = "f13";
                };
            };
        };
    };
}
