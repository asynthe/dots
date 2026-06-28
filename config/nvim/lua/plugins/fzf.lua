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

local function notes_picker()
  local fzf = require("fzf-lua")
  local notes_dir = vim.fn.expand("~/notes")
  local files = vim.fn.systemlist(
    "find " .. vim.fn.shellescape(notes_dir) .. " -name '*.md' -type f 2>/dev/null"
  )

  local entries = {}
  local path_map = {}

  for _, path in ipairs(files) do
    local display = get_note_title(path) or vim.fn.fnamemodify(path, ":t:r")
    -- deduplicate display names that map to different files
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

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>.",  notes_picker,              desc = "fzf: open note" },
      { "<leader>zf", "<cmd>FzfLua files<CR>",   desc = "fzf: files" },
      { "<leader>zg", "<cmd>FzfLua live_grep<CR>", desc = "fzf: live grep" },
      { "<leader>zb", "<cmd>FzfLua buffers<CR>", desc = "fzf: buffers" },
    },
    opts = {},
  },
}
