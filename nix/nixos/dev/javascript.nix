{ ... }:
{
    flake.modules.nixos.javascript = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            nodejs_22
            yarn
            typescript
            typescript-language-server
            prettierd
            eslint_d
        ];
    };
}
