local opts = { noremap = true, silent = true }

-- ───────────────────────── Modules ─────────────────────────
-- Window Management
vim.keymap.set("n", "<leader>wc", ":q<CR>", opts)
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", opts)
vim.keymap.set("n", "<leader>ws", ":split<CR>", opts)

-- Buffers
vim.keymap.set("n", "<A-]>", ":bnext<CR>", opts)
vim.keymap.set("n", "<A-[>", ":bprev<CR>", opts)
vim.keymap.set("n", "<leader>fs", ":w<CR>", opts)

-- Kill buffer and close nvim if only that buffer left
vim.keymap.set("n", "<leader>bk", function()
    if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
        vim.cmd("q")
    else
        vim.cmd("bd")
    end
end, { noremap = true, silent = true, desc = "Kill buffer or quit" })

-- Comments
vim.api.nvim_set_keymap("n", "<C-_>", "gcc", { noremap = false })
vim.api.nvim_set_keymap("v", "<C-_>", "gcc", { noremap = false })

-- ───────────────────────── Plugin Keymaps ─────────────────────────
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

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    vim.keymap.set("n", "<leader>fl", function() toggle_telescope(harpoon:list()) end, { desc = "Open Harpoon Telescope" })
    vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)
end

-- Telescope
local telescope_ok, telescope = pcall(require, "telescope.builtin")
if telescope_ok then
    vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' })
end

-- ───────────────────────── Neorg keybinds ─────────────────────────
vim.api.nvim_create_autocmd("Filetype", {
    pattern = "norg",
    callback = function()
        local opts = { buffer = true, silent = true, noremap = true }

        -- Main keybinds
        vim.keymap.set("n", "<A-Left>", "<Plug>(neorg.promo.demote)", { buffer = true })
        vim.keymap.set("n", "<A-Right>", "<Plug>(neorg.promo.promote)", { buffer = true })

        -- Tab to fold headings in normal and insert
        vim.keymap.set("n", "<Tab>", function()
            pcall(function() vim.cmd("normal! za") end)
        end, opts)

        vim.keymap.set("i", "<Tab>", function()
            pcall(function()
                vim.cmd("stopinsert")
                vim.cmd("normal! za")
                vim.cmd("startinsert")
            end)
        end, opts)

        vim.keymap.set("i", "<A-Left>", "<Plug>(neorg.promo.demote)", { buffer = true })
        vim.keymap.set("i", "<A-Right>", "<Plug>(neorg.promo.promote)", { buffer = true })
    end,
})
