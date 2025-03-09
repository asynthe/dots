local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Require (Adding the files here)
require('config.globals')
require('config.options')
require('config.keymaps')
-- require('config.globals')

local opts = {
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "carbonfox" }
	},
	rtp = {
		disabled_plugins = {
	"gzip",
	"matchit",
	"matchparen",
	"netrwPlugin",
	"tohtml",
	"tutor",
	"zipPlugin",
	       }
	},
	change_detection = {
		notify = true,
	},
}

require("lazy").setup('plugins')

-- lsp-zero
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)
