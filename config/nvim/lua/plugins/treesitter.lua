local moves = {
  { "]f", "goto_next_start",     "@function.outer", "Next function" },
  { "[f", "goto_previous_start", "@function.outer", "Prev function" },
  { "]c", "goto_next_start",     "@class.outer",    "Next class" },
  { "[c", "goto_previous_start", "@class.outer",    "Prev class" },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash",
        "python",
        "nix",
        "sql",
        "rust",
        "go",
        "typescript",
        "tsx",
        "javascript",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "query",
        "diff",
        "git_rebase",
        "gitcommit",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
      })
      for _, m in ipairs(moves) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          require("nvim-treesitter-textobjects.move")[m[2]](m[3], "textobjects")
        end, { desc = m[4] })
      end
    end,
  },
}
