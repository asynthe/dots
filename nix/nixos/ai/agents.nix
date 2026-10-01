{ ... }:
{
    flake.modules.nixos.claude-code = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.claude-code ];
    };

    flake.modules.nixos.codex = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.codex ];
    };

    flake.modules.nixos.opencode = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.opencode ];
    };
}
