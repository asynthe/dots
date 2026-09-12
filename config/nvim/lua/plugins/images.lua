local host = require("host")

return {
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    cond = function() return host.graphics_terminal() and host.has("magick") end,
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 100,
      max_height = 20,
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = false,
    },
  },
}
