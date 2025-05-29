return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- also "echasnovski/mini.icons"
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Read ASCII art from file
        local function read_ascii_art(filepath)
            local lines = {}
            for line in io.lines(filepath) do
                table.insert(lines, line)
            end
            return lines
        end

        -- Load ASCII art
        local ascii = read_ascii_art(vim.fn.stdpath("config") .. "/../../other/ascii/hydra")
        dashboard.section.header.val = ascii

        -- Sections
        dashboard.section.footer.val = "Neovimへようこそ！"
        dashboard.section.buttons.val = {
            dashboard.button("n", "󱞁 Notes", ":cd ~/notes/neorg | e index.norg<CR>"),
            dashboard.button("f", "󰍉 Find file", ":Telescope find_files<CR>"),
            dashboard.button("l", "󰒲 Lazy", ":Lazy<CR>"),
            dashboard.button("q", "󰩈 Exit", ":qa<CR>"),
        }

        -- Setup alpha
        alpha.setup(dashboard.config)
    end,
}
