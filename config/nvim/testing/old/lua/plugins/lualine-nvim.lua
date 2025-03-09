-- local config = function()
-- 	local theme = require("lualine.themes.carbonfox")
--
-- 	theme.normal.c.bg = nil
-- 	-- set bg transparency in all modes
-- -- 	theme.normal.c.bg = nil
-- -- 	theme.insert.c.bg = nil
-- -- - theme.visual.c.bg = nil
-- -- 	theme.replace.c.bg = nil
-- -- 	theme.command.c.bg = nil
--
-- 	require("lualine").setup({
-- 		options = {
-- 			theme = theme,
-- 			globalstatus = true,
-- 		},
-- 		tabline = {
-- 			lualine_a = { "mode" },
-- 			lualine_b = { "buffers" },
-- 			lualine_x = { "encoding", "fileformat", "filetype" },
-- 			lualine_y = { "progress" },
-- 			--lualine_z = { "%P" },
-- 			lualine_z = { "location" },
-- 		},
-- 		sections = {},

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	config = config,
}
