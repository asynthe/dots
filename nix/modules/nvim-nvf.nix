/*
https://github.com/AntonioDrumond/flake_laptop/blob/d226c4b58ba5e28d4788beef19594349f339693b/nvf.nix
https://github.com/kripticni/NixOS/blob/4fff70739da350614a767025557da90b31f7d9a4/hosts/common/opts/nvf/default-nord.nix
https://github.com/AntonioDrumond/flake_laptop/blob/d226c4b58ba5e28d4788beef19594349f339693b/nvf.nix
https://github.com/ErrorNoInternet/configuration.nix/blob/8a5f9c31e3e6d97f4dc7b89ff9bbb118b60b477e/nvf/plugins/obsidian.nix
*/

{ config, lib, pkgs, ... }: 
let
    cfg = config.sys.modules.nvim-nvf;
in {
    options.sys.modules.nvim-nvf = {
        enable = lib.mkEnableOption "nvim-nvf";
    };

    config = lib.mkIf cfg.enable {

        environment.systemPackages = with pkgs; [
            nodejs
        ];

        programs.nvf.enable = true;
        programs.nvf.settings.vim = {
            theme.enable = true;
            theme.transparent = true;
            #theme.name = "gruvbox";
            #theme.style = "dark";

            # Plugins
            git.enable = true;
            git.gitsigns.enable = true;
            autocomplete.nvim-cmp.enable = true;
            lsp.enable = true;
            statusline.lualine.enable = true;
            telescope.enable = true;
            fzf-lua.enable = true;

            # Languages for treesitter
            languages = {
                enableTreesitter = true;
                markdown.enable = true;
                markdown.extensions.render-markdown-nvim.enable = true;
                bash.enable = true;
                python.enable = true;
                nix.enable = true;
                rust.enable = true;
                typescript.enable = true;
            };

            # Utility plugins
            utility = {
                oil-nvim.enable = true;
                oil-nvim.gitStatus.enable = true;
                preview.markdownPreview.enable = true;
                images.image-nvim.enable = true;
            };

            # Note-taking
            notes = {
                obsidian = {
                    enable = true;
                    setupOpts.legacy_commands = false;
                    setupOpts.workspaces = [
                        {
                            name = "main";
                            path = "~/sync/notes";
                        }
                    ];
                };
                neorg.enable = true;
                neorg.treesitter.enable = true;
            };

            # Neovim options
            options = {
                clipboard = "unnamedplus";

                # Line Numbers
                number = false;
                relativenumber = false;
                signcolumn = "yes";
                termguicolors = true;

                # Mouse scroll
                mousescroll = "ver:1";
                scrolloff = 0;
                sidescrolloff = 0;

                # Wrapping
                wrap = true;
                showbreak = "→ ";
                linebreak = true;
                breakindent = true;
                splitbelow = true;
                splitright = true;

                # Indenting
                expandtab = true;
                tabstop = 4;
                shiftwidth = 4;
                softtabstop = 4;
                autoindent = true;
                smartindent = true;

                # Searching
                ignorecase = true;
                smartcase = true;
                hlsearch = true;
                incsearch = true;

                # Keybind Behavior
                timeoutlen = 500;
                updatetime = 300;

                # Performance
                lazyredraw = true;
                synmaxcol = 300;

                # File Handling
                undofile = true;
                swapfile = false;
                backup = false;
                writebackup = false;
            };

            # Filetype-specific options
            autocmds = [
                {
                    event = [ "FileType" ];
                    pattern = [ "markdown" ];
                    command = "setlocal nofoldenable";
                }
            ];
        };
    };
}
