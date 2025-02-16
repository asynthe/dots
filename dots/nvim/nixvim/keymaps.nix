{
    programs.nixvim = {
	globals.mapleader = " "; # Space
	keymaps = [

	    # Indenting
	    {
		mode = "v";
		key = "<";
		action = "<gv";
	    }
	    {
		mode = "v";
		key = ">";
		action = ">gv";
	    }

	    # Telescope
	    {
		mode = "n";
		key = "<leader>ff";
		action = "<cmd>Telescope find_files<CR>";
	    }
	    {
		mode = "n";
		key = "<leader>g";
		action = "<cmd>Telescope live_grep<CR>";
	    }

	    # Nvim-tree
	    {
		mode = "n";
		key = "<leader>.";
		action = "<cmd>:NvimTreeFocus<CR>";
	    }
	    {
		mode = "n";
		key = "<leader>m";
		action = "<cmd>:NvimTreeToggle<CR>";
	    }

	    # Folding
	    {
		mode = "n";
		key = "<Space>";
		action = "@=(foldlevel('.')?'za':\"\<Space>\")<CR>";
		options = {
		    silent = true;
		    remap = false;
		};
	    }

	    # Window Splits
	    {
		mode = "n";
		key = "<leader>wc";
		action = ":q<CR>";
		options = {
		    remap = false;
		    silent = true;
		};
	    }
	    {
		mode = "n";
		key = "<leader>M";
		action = ":MaximizerToggle<CR>";
		options = {
		    remap = false;
		    silent = true;
		};
	    }
	    {
		mode = "n";
		key = "<leader>wv";
		action = ":vsplit<CR>";
		options = {
		    remap = false;
		    silent = true;
		};
	    }
	    {
		mode = "n";
		key = "<leader>ws";
		action = ":split<CR>";
		options = {
		    remap = false;
		    silent = true;
		};
	    }

	    {
		mode = "n";
		key = "<C-h>";
		action = "<C-w>h";
		options = {
		    remap = false;
		};
	    }
	    {
		mode = "n";
		key = "<C-j>";
		action = "<C-w>j";
		options = {
		    remap = false;
		};
	    }
	    {
		mode = "n";
		key = "<C-k>";
		action = "<C-w>k";
		options = {
		    remap = false;
		};
	    }
	    #{
		#mode = "n";
		#key = "<C-l>";
		#action = "<C-w>l";
		#options = {
		    #remap = false;
		#};
	    #}
	    #{
		#mode = "n";
		#key = "<C-l>";
		#action = "winnr('l') == winnr() ? ':vsp<CR>' : '<C-w>l'";
		#options = {
		#    expr = true;
		#    remap = false;
		#};
	    #}
	];
    };
}
