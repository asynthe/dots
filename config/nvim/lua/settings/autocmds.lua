-- Need to make Neorg update folding
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.norg",
  callback = function()
    vim.defer_fn(function()
      if vim.bo.filetype == "norg" then
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
        vim.opt_local.foldenable = false  -- optional: start with all folds closed
        vim.cmd("normal! zx")             -- recompute folds immediately
      end
    end, 50) -- delay slightly to let Neorg/treesitter initialize
  end,
})
