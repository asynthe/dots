local M = {}

local uname = vim.uv.os_uname()

M.sysname = uname.sysname
M.is_mac = uname.sysname == "Darwin"
M.is_linux = uname.sysname == "Linux"
M.is_nixos = vim.uv.fs_stat("/etc/NIXOS") ~= nil

function M.has(exe)
  return vim.fn.executable(exe) == 1
end

function M.graphics_terminal()
  if os.getenv("GHOSTTY_RESOURCES_DIR") then return true end
  local term = os.getenv("TERM") or ""
  return term:find("kitty") ~= nil or os.getenv("KITTY_WINDOW_ID") ~= nil
end

return M
