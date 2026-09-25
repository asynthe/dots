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
        dashboard.button(".", "open note", "<cmd>lua require('core.notes').picker()<CR>"),
        dashboard.button("m", "main.md",   "<cmd>edit ~/git/notes/main.md<CR>"),
        dashboard.button("f", "find file", "<cmd>Yazi cwd<CR>"),
        dashboard.button("q", "quit",      "<cmd>qa<CR>"),
      }

      local width = 0
      for _, b in ipairs(dashboard.section.buttons.val) do
        local w = vim.fn.strdisplaywidth(b.val) + vim.fn.strdisplaywidth(b.opts.shortcut)
        width = math.max(width, w)
      end
      for _, b in ipairs(dashboard.section.buttons.val) do
        b.opts.width = width + 4
      end

      dashboard.section.footer.val = os.date("  %A, %B %d")

      dashboard.config.layout = {
        {
          type = "group",
          opts = { position = "v_center" },
          val = {
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            dashboard.section.footer,
          },
        },
      }

      alpha.setup(dashboard.config)
    end,
  },
}
