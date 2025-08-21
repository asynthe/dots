{ pkgs, inputs, ... }: {

    programs.neovim.enable = true;
    environment.systemPackages = with pkgs; [
        git
        gcc
        tree-sitter
        curl
        unzip
        pkg-config
        cmake
        meson
        ninja
        boost
        fmt
        
        lua-language-server
        vimPlugins.mason-lspconfig-nvim

        # Neorg
        vimPlugins.neorg
        inputs.norgolith.packages.${pkgs.system}.default
    ];
}
