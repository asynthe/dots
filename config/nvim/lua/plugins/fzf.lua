local function buffers()
  require("fzf-lua").buffers({
    winopts = {
      height = 0.6,
      width = 0.85,
      preview = { layout = "horizontal", horizontal = "right:55%" },
    },
  })
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader><leader>", "<cmd>FzfLua files<CR>",      desc = "Find files" },
      { "<leader>/",        "<cmd>FzfLua live_grep<CR>",  desc = "Grep project" },
      { "<leader>,",        buffers,                      desc = "Buffers" },
      { "<leader>?",        "<cmd>FzfLua keymaps<CR>",    desc = "Keymaps" },
      { "<leader>fr",       "<cmd>FzfLua oldfiles<CR>",   desc = "Recent files" },
      { "<leader>fw",       "<cmd>FzfLua grep_cword<CR>", desc = "Grep word under cursor" },
      { "<leader>fh",       "<cmd>FzfLua helptags<CR>",   desc = "Help tags" },
      { "<leader>fz",       "<cmd>FzfLua resume<CR>",     desc = "Resume last picker" },
    },
    opts = {
      winopts = { border = "rounded", preview = { layout = "vertical" } },
    },
  },
}
