return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "   ╱|、",
        "  (˚ˎ 。7",
        "   |、˜〵",
        "   じしˍ,)ノ",
      }

      dashboard.section.buttons.val = {
        dashboard.button(".", "open note",    "<cmd>lua require('core.notes').picker()<CR>"),
        dashboard.button("m", "main.md",      "<cmd>edit ~/notes/main.md<CR>"),
        dashboard.button("r", "recent",       "<cmd>FzfLua oldfiles<CR>"),
        dashboard.button("q", "quit",         "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = os.date("  %A, %B %d")

      alpha.setup(dashboard.config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          vim.opt.laststatus = 0
          -- lualine loads after AlphaReady (VeryLazy), re-hide once all plugins are done
          vim.api.nvim_create_autocmd("User", {
            pattern = "LazyDone",
            once = true,
            callback = function()
              if vim.api.nvim_get_current_buf() == buf then
                vim.opt.laststatus = 0
              end
            end,
          })
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = buf,
            callback = function() vim.opt.laststatus = 3 end,
          })
        end,
      })
    end,
  },
}
