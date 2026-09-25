{ ... }:
{
    flake.modules.nixos.typst = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            typst

            et-book
            garamond-libre
            nerd-fonts.zed-mono
        ];
    };
}
