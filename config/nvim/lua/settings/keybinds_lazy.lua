local opts = { noremap = true, silent = true }
local function kill_buffer_or_quit()
    if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.cmd("q")
    else
        vim.cmd("bd")
    end
end

-- ───────────────────────── which-key ─────────────────────────
local wk = require("which-key")
wk.add({
    { "<leader>f", group = "File operations" },
    { "<leader>j", group = "Journal" },
    { "<leader>l", group = "List files (Harpoon)" },
    { "<leader>n", group = "Notes" },
    { "<leader>t", group = "Toggle / Disable" },
    { "<leader>w", group = "Window operations" },
})

-- ───────────────────────── NORMAL MODE ─────────────────────────
local telescope = require("telescope.builtin")

-- Main
vim.keymap.set("n", "<leader>.", "<cmd>Yazi<cr>", { noremap = true, silent = true, desc = "Yazi file manager" })
vim.keymap.set("n", "<leader>,", ":Oil<CR>", { noremap = true, silent = true, desc = "Oil file manager" })

-- File operations
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "List buffers (Telescope)" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "File live grep (Telescope)" })
vim.keymap.set("n", "<leader>fk", kill_buffer_or_quit, { noremap = true, silent = true, desc = "Close file" })
vim.keymap.set("n", "<leader>fl", telescope.find_files, { desc = "Find files (Telescope)" })
vim.keymap.set("n", "<leader>fs", ":w<CR>", { noremap = true, silent = true, desc = "Save file" })

-- Notes
vim.keymap.set("n", "<leader>nf", function()
    require("telescope.builtin").find_files({
        cwd = vim.fn.expand("~/notes"),
    })
end, { desc = "Search on notes directory" })

-- Toggle / Disable
vim.keymap.set("n", "<leader>tm", ":Alpha<CR>", { noremap = true, silent = true, desc = "Open Alpha dashboard" })
vim.keymap.set("n", "<leader>tt", ":NvimTreeFocus<CR>", { noremap = true, silent = true, desc = "Open nvim-tree" })

-- Window operations
vim.keymap.set("n", "<leader>wc", ":q<CR>", { noremap = true, silent = true, desc = "Close window" })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { noremap = true, silent = true, desc = "Split window (vertical)" })
vim.keymap.set("n", "<leader>ws", ":split<CR>", { noremap = true, silent = true, desc = "Split window (horizontal)" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { noremap = true, silent = true, desc = "Change to buffer in left" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { noremap = true, silent = true, desc = "Change to buffer in down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { noremap = true, silent = true, desc = "Change to buffer in up" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { noremap = true, silent = true, desc = "Change to buffer in right" })
--vim.keymap.set("n", "<leader>\\", ":vsplit<CR>", opts)
--vim.keymap.set("n", "<leader>|", ":split<CR>", opts)

-- Buffers
vim.keymap.set("n", "<C-]>", ":bprev<CR>", opts)
vim.keymap.set("n", "<C-[>", ":bnext<CR>", opts)

-- Window resizing
--vim.keymap.set("n", "H", ":vertical resize -2<CR>", opts)
--vim.keymap.set("n", "J", ":resize +2<CR>", opts)
--vim.keymap.set("n", "K", ":resize -2<CR>", opts)
--vim.keymap.set("n", "L", ":vertical resize +2<CR>", opts)

-- Terminal
--vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>", opts)
--vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>", opts)
--vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>", opts)
--vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>", opts)

-- ───────────────────────── VISUAL MODE ─────────────────────────
vim.keymap.set("v", "<", "<gv", opts) -- Indent
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts) -- Move selected lines up or down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- ───────────────────────── Plugin Keymaps ─────────────────────────
-- Lualine
local lualine_hidden = false
vim.keymap.set("n", "<leader>tl", function()
  lualine_hidden = not lualine_hidden
  require("lualine").hide({ unhide = lualine_hidden })
end, { desc = "Toggle lualine" })

-- Harpoon
local harpoon_ok, harpoon = pcall(require, "harpoon")
if harpoon_ok then
    local conf = require("telescope.config").values
    local themes = require("telescope.themes")

    -- helper function to use telescope on harpoon list.
    -- change get_ivy to other themes if wanted
    local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
        end
        local opts = themes.get_ivy({
            prompt_title = "Working List"
        })

        require("telescope.pickers").new(opts, {
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
        }):find()
    end

    -- List (Harpoon Keybindings)
    vim.keymap.set("n", "<leader>la", function() harpoon:list():add() end, { desc = "Add to list" })
    vim.keymap.set("n", "<leader>lm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "List menu" })
    vim.keymap.set("n", "<leader>lt", function() toggle_telescope(harpoon:list()) end, { desc = "Open list on Telescope" })
    vim.keymap.set("n", "<leader>ln", function() harpoon:list():prev() end, { desc = "List next" })
    vim.keymap.set("n", "<leader>lp", function() harpoon:list():next() end, { desc = "List previous" })
end
