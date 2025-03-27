local opt = vim.opt
local g = vim.g

-- 🖥️ UI Settings
opt.number = true          -- Show line numbers
opt.relativenumber = true  -- Show relative numbers
opt.cursorline = true      -- Highlight the current line
opt.signcolumn = "yes"     -- Always show the sign column to prevent UI shifting
opt.termguicolors = true   -- Enable 24-bit colors

-- Scroll
opt.mousescroll = "ver:1"
opt.scrolloff = 0
opt.sidescrolloff = 0
--opt.scrolloff = 8          -- Keep at least 8 lines above/below the cursor
--opt.sidescrolloff = 8      -- Keep at least 8 columns left/right of the cursor

-- 📜 Wrapping and Splitting
opt.wrap = true                 -- Enable line wrapping
opt.showbreak = "→ "            -- Wrapped line indicator
opt.linebreak = true            -- Prevent words from breaking in the middle
opt.breakindent = true          -- Keep indentation for wrapped lines
opt.splitbelow = true           -- Split windows below
opt.splitright = true           -- Split windows to the right

-- 📄 Indentation and Formatting
opt.expandtab = true       -- Convert tabs to spaces
opt.tabstop = 4            -- Set tab width to 4 spaces
opt.shiftwidth = 4         -- Indentation width
opt.softtabstop = 4        -- Soft tab size
opt.autoindent = true      -- Auto-indent new lines
opt.smartindent = true     -- Enable smart indentation

-- 🔍 Searching
opt.ignorecase = true      -- Ignore case in searches...
opt.smartcase = true       -- ...but be case-sensitive if uppercase is used
opt.hlsearch = true        -- Highlight search results
opt.incsearch = true       -- Show search matches as you type

-- 🔄 File Handling
opt.undofile = true        -- Enable undo history across sessions
opt.swapfile = false       -- Disable swap files
opt.backup = false         -- Disable backup files
opt.writebackup = false    -- Don't write a backup before overwriting

-- ⌨️ Keybind Behavior
opt.timeoutlen = 500       -- Timeout for mapped sequences (ms)
opt.updatetime = 300       -- Faster update time for better responsiveness


-- 🖊️ Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- 🏎️ Performance Optimizations
opt.lazyredraw = true      -- Optimize redrawing for macros and scripts
opt.synmaxcol = 300        -- Stop syntax highlighting after X columns

-- ✅ Set global variables (for plugins or defaults)
g.mapleader = " "          -- Space as the leader key
