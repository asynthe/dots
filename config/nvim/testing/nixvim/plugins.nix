{
    programs.nixvim.plugins = {

        # UI
	    lightline.enable = true;
        transparent.enable = true;
        web-devicons.enable = true;
        
        # Plugins
        oil.enable = true; # `nvim .` will open oil instead of netrw
        telescope.enable = true;
        luasnip.enable = true;
        
        # Nicer code
        treesitter.enable = true; # All parsers included.
        illuminate.enable = true;
        
        # File Search
        nvim-tree = {
            enable = true;
            filters.dotfiles = true;
        };
        
        # Note-taking
        #neorg.enable = true; # Not yet implemented.
        
        # QOL
        nvim-autopairs.enable = true;
        #indent-blankline.enable = true;
        
        # Tabs
        #barbar = {
            #enable = true;
            #settings = {
                #insertAtEnd = true;
                #autoHide = true;
                #animation = false;
                #excludeFileNames = [];
                #insertAtStart = true;
            #};
        #};
        
        lsp = {
            enable = true;
            servers = {
        	    bashls.enable = true;
        	    lua_ls.enable = true; # Lua
        	    nil_ls.enable = true; # Nix
        	    rust_analyzer = {
                    enable = true; # Rust
                    installCargo = true;
                    installRustc = true;
                };
            };
        };
        cmp = {
            enable = true;
            autoEnableSources = true;
            settings = {
        	sources = [
        	    { name = "nvim_lsp";}
        	    { name = "path"; }
        	    { name = "buffer"; }
        	    { name = "luasnip"; }
        	];
        
        	mapping = {
        	    #"<C-Space>" = "cmp.mapping.complete()";
        	    "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        	    "<C-f>" = "cmp.mapping.scroll_docs(4)";
        	    "<C-e>" = "cmp.mapping.close()";
        	    "<Escape>" = "cmp.mapping.abort()";
        
        	    "<CR>" = "cmp.mapping.confirm({ select = true })";
        	    "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        	    "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        	    "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        	    "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                };
            };
        };
    };
}
