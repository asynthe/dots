local M = {}

local function get_note_title(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local id, heading, in_front, n = nil, nil, false, 0
  for line in f:lines() do
    n = n + 1
    if n == 1 and line:match("^---") then
      in_front = true
    elseif in_front and line:match("^---") then
      in_front = false
    elseif in_front then
      id = id or line:match("^id:%s*(.+)$")
    elseif not heading then
      heading = line:match("^# (.+)")
    end
    if not in_front and heading then break end
    if n > 60 then break end
  end
  f:close()
  return id or heading
end

function M.picker()
  local fzf = require("fzf-lua")
  local notes_dir = require("host").git_root .. "/notes"
  local files = vim.fs.find(function(name) return name:match("%.md$") ~= nil end,
    { path = notes_dir, type = "file", limit = math.huge })

  local entries = {}
  local path_map = {}

  for _, path in ipairs(files) do
    local display = get_note_title(path) or vim.fn.fnamemodify(path, ":t:r")
    local key = display
    local n = 1
    while path_map[key] do
      n = n + 1
      key = display .. " (" .. n .. ")"
    end
    path_map[key] = path
    table.insert(entries, key)
  end

  fzf.fzf_exec(entries, {
    prompt = "Notes> ",
    actions = {
      ["default"] = function(sel)
        if sel and sel[1] and path_map[sel[1]] then
          vim.cmd("edit " .. vim.fn.fnameescape(path_map[sel[1]]))
        end
      end,
    },
  })
end

local function daily_dir()
  return require("host").git_root .. "/notes/daily"
end

function M.daily_folder()
  local dir = daily_dir()
  vim.fn.mkdir(dir, "p")
  require("yazi").yazi(nil, dir)
end

function M.daily_latest()
  local files = vim.fn.glob(daily_dir() .. "/*.md", true, true)
  if #files == 0 then
    vim.notify("no daily notes yet", vim.log.levels.WARN)
    return
  end
  table.sort(files)
  vim.cmd("edit " .. vim.fn.fnameescape(files[#files]))
end

return M
