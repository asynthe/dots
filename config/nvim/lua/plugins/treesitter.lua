local parsers = {
  "bash", "python", "nix", "sql", "rust", "go", "typescript", "tsx",
  "javascript", "json", "yaml", "toml", "markdown", "markdown_inline",
  "lua", "luadoc", "vim", "vimdoc", "query", "diff", "git_rebase", "gitcommit",
}

local moves = {
  { "]f", "goto_next_start",     "@function.outer", "Next function" },
  { "[f", "goto_previous_start", "@function.outer", "Prev function" },
  { "]c", "goto_next_start",     "@class.outer",    "Next class" },
  { "[c", "goto_previous_start", "@class.outer",    "Prev class" },
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install(parsers)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end
          vim.treesitter.start(args.buf, lang)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
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
