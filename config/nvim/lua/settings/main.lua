-- ───────────────────────── Configuration ─────────────────────────
-- Line Numbers
vim.opt.number = false
vim.opt.relativenumber = false
--vim.opt.number = true
--vim.opt.relativenumber = true

-- UI Settings
--vim.opt.cursorline = true     -- Highlight the current line
vim.opt.signcolumn = "yes"    -- Always show the sign column to prevent UI shifting
vim.opt.termguicolors = true  -- Enable 24-bit colors

-- Folding
vim.opt.foldtext = [[
  getline(v:foldstart) .. ' ...'
]]

vim.opt.fillchars:append ({
    fold = " ",
    eob = " "
})

-- Scroll
vim.opt.mousescroll = "ver:1"
vim.opt.scrolloff = 0
vim.opt.sidescrolloff = 0
--vim.opt.scrolloff = 8          -- Keep at least 8 lines above/below the cursor
--vim.opt.sidescrolloff = 8      -- Keep at least 8 columns left/right of the cursor

-- Settings
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Wrapping and Splitting
vim.opt.wrap = true -- Enable line wrapping
vim.opt.showbreak = "→ " -- Wrapped line indicator
vim.opt.linebreak = true -- Prevent words from breaking in the middle
vim.opt.breakindent = true -- Keep indentation for wrapped lines

-- Splitting
vim.opt.splitbelow = true -- Split windows below
vim.opt.splitright = true -- Split windows to the right

-- Indentation and Formatting
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.tabstop = 4        -- Set tab width to 4 spaces
vim.opt.shiftwidth = 4     -- Indentation width
vim.opt.softtabstop = 4    -- Soft tab size
vim.opt.autoindent = true  -- Auto-indent new lines
vim.opt.smartindent = true -- Enable smart indentation

-- Searching
vim.opt.ignorecase = true -- Ignore case in searches...
vim.opt.smartcase = true  -- ...but be case-sensitive if uppercase is used
vim.opt.hlsearch = true   -- Highlight search results
vim.opt.incsearch = true  -- Show search matches as you type

-- File Handling
vim.opt.undofile = true     -- Enable undo history across sessions
vim.opt.swapfile = false    -- Disable swap files
vim.opt.backup = false      -- Disable backup files
vim.opt.writebackup = false -- Don't write a backup before overwriting

-- Keybind Behavior
vim.opt.timeoutlen = 500 -- Timeout for mapped sequences (ms)
vim.opt.updatetime = 300 -- Faster update time for better responsiveness

-- Performance Optimizations
vim.opt.lazyredraw = true -- Optimize redrawing for macros and scripts
vim.opt.synmaxcol = 300   -- Stop syntax highlighting after X columns
