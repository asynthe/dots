local opts = { noremap = true, silent = true }
local function kill_buffer_or_quit()
    if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.cmd("q")
    else
        vim.cmd("bd")
    end
end

-- ───────────────────────── NORMAL MODE ─────────────────────────
local telescope = require("telescope.builtin")

--vim.keymap.set("n", "<leader>.", ":Oil<CR>", opts)
--vim.keymap.set("n", "<Tab>", ":NvimTreeFocus<CR>", opts)
--vim.keymap.set("n", "<leader>.", "<cmd>Yazi<cr>", opts)
vim.keymap.set("n", "<leader>.", telescope.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ft", ":NvimTreeFocus<CR>", opts)
vim.keymap.set("n", "<leader>fm", ":Alpha<CR>", opts)
vim.keymap.set("n", "<leader>g", telescope.live_grep, { desc = "Telescope live grep" })

-- Telescope (Find files)
vim.keymap.set("n", "<leader>fs", ":w<CR>", opts) -- Save file
vim.keymap.set("n", "<leader>fk", kill_buffer_or_quit, opts) -- Kill buffer or exit if one buffer left
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>nl", telescope.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>nf", telescope.find_files, { desc = "Telescope find files" })

-- Buffers
vim.keymap.set("n", "<A-]>", ":bprev<CR>", opts)
vim.keymap.set("n", "<A-[>", ":bnext<CR>", opts)

-- Window splits
--vim.keymap.set("n", "<leader>\\", ":vsplit<CR>", opts)
--vim.keymap.set("n", "<leader>|", ":split<CR>", opts)
--vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", opts)
--vim.keymap.set("n", "<leader>ws", ":split<CR>", opts)

-- Window navigation
--vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
--vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
--vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
--vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

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
vim.keymap.set("n", "<leader>st", function()
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

    -- Harpoon Keybindings
    vim.keymap.set("n", "<leader>na", function() harpoon:list():add() end)
    vim.keymap.set("n", "<leader>nl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    vim.keymap.set("n", "<leader>nt", function() toggle_telescope(harpoon:list()) end, { desc = "Open Harpoon Telescope" })
    vim.keymap.set("n", "<leader>nn", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<leader>np", function() harpoon:list():next() end)
end
