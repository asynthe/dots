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
      { "<C-e>",            buffers,                                 desc = "Switch buffer" },
      { "<leader><leader>", "<cmd>FzfLua files<CR>",               desc = "Find files" },
      { "<leader>ff",       "<cmd>FzfLua files<CR>",               desc = "Find files" },
      { "<leader>fg",       "<cmd>FzfLua live_grep<CR>",           desc = "Grep project" },
      { "<leader>fb",       buffers,                               desc = "Find buffers" },
      { "<leader>fr",       "<cmd>FzfLua oldfiles<CR>",            desc = "Recent files" },
      { "<leader>fw",       "<cmd>FzfLua grep_cword<CR>",          desc = "Grep word under cursor" },
      { "<leader>fh",       "<cmd>FzfLua helptags<CR>",            desc = "Help tags" },
      { "<leader>fd",       "<cmd>FzfLua diagnostics_document<CR>", desc = "Document diagnostics" },
      { "<leader>fD",       "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Workspace diagnostics" },
      { "<leader>fm",       "<cmd>FzfLua keymaps<CR>",             desc = "Keymaps" },
      { "<leader>fz",       "<cmd>FzfLua resume<CR>",              desc = "Resume last picker" },
    },
    opts = {
      winopts = { border = "rounded", preview = { layout = "vertical" } },
    },
  },
}
