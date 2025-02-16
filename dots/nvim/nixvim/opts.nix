{ config, nixvim, ... }: {

    programs.nixvim = {
    	clipboard = {
		    # IMPLEMENT
		    # if x -> xclip
		    # if wayland -> wl-copy
		    register = "unnamedplus";
		    providers.wl-copy.enable = true;
	    };

    	#highlight = {
	        #Comment.fg = "#ff00ff";
	        #Comment.bg = "#000000";
	        #Comment.underline = true;
	        #Comment.bold = true;
	    #};

    	opts = {

		    # Tab / Indentation
		    expandtab = true;
		    shiftwidth = 4;
		    smartindent = true;
		    softtabstop = 2;
		    tabstop = 4;
		    wrap = true;

		    # Appearance
		    cmdheight = 1;
		    colorcolumn = "";
		    #colorcolumn = "100";
		    completeopt = "menuone,noinsert,noselect";
		    number = true;
		    scrolloff = 10;
		    signcolumn = "yes";
		    termguicolors = true;
            fillchars.eob = " "; # Replace the empty lines `~` for a space. 

		    # Search
		    hlsearch = false;
		    ignorecase = true;
		    incsearch = true;
		    smartcase = true;

		    # Split behaviour
		    splitbelow = true;
		    splitright = true;

	    	# Behaviour
		    mouse = "a";
		    hidden = true;
		    errorbells = false;
		    swapfile = false;
            virtualedit = "block"; # Allow cursor to move where there is no text in visual block mode.
	    };

        extraConfigLua = ''
          -- Set LineNr line background to transparent
          vim.api.nvim_set_hl(0, "LineNr", { bg='NONE' })

          -- Set CursorLineNr background to transparent
          vim.api.nvim_set_hl(0, "CursorLineNr", { bg='NONE' })

          -- Set SignColumn background to transparent
          vim.api.nvim_set_hl(0, "SignColumn", { bg='NONE' })

          -- Set EndOfBuffer background to transparent
          vim.api.nvim_set_hl(0, "EndOfBuffer", { bg='NONE' })
        '';
    };
}
