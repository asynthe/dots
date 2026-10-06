-- Live preview for Typst books. A file belongs to the nearest book.typ above
-- it (sakuhin layout: NNNN_slug/book.typ + chapters/), or to itself if none.
-- `typst watch` recompiles on save and the viewer reloads the PDF by itself:
-- SumatraPDF on Windows, zathura on Linux, Preview on macOS.
local host = require("host")

local M = {}

local watches = {} -- book.typ -> job id

function M.book(buf)
  local file = vim.api.nvim_buf_get_name(buf or 0)
  local dir = vim.fs.dirname(file)
  return vim.fs.find("book.typ", { upward = true, path = dir })[1] or file
end

local function viewer()
  if host.is_mac then return { "open" } end
  if host.has("zathura") then return { "zathura" } end
  if host.is_windows then
    local sumatra = vim.fs.normalize("$LOCALAPPDATA/SumatraPDF/SumatraPDF.exe")
    if host.has("SumatraPDF") then return { "SumatraPDF", "-reuse-instance" } end
    if vim.uv.fs_stat(sumatra) then return { sumatra, "-reuse-instance" } end
  end
end

-- The first compile of a new book takes a moment; wait for the PDF to exist.
local function open_when_ready(pdf, tries)
  if vim.uv.fs_stat(pdf) then
    local cmd = viewer()
    if not cmd then return vim.notify("no PDF viewer found", vim.log.levels.WARN) end
    table.insert(cmd, pdf)
    vim.system(cmd, { detach = true })
  elseif tries > 0 then
    vim.defer_fn(function() open_when_ready(pdf, tries - 1) end, 250)
  else
    vim.notify("no " .. pdf .. " yet, the book has errors?", vim.log.levels.WARN)
  end
end

function M.preview()
  local book = M.book()
  local dir = vim.fs.dirname(book)
  if not watches[book] then
    -- same rule as build.sh: bundled fonts only when the book ships them
    local cmd = { "typst", "watch" }
    if vim.uv.fs_stat(dir .. "/fonts") then
      vim.list_extend(cmd, { "--font-path", dir .. "/fonts" })
    end
    table.insert(cmd, book)
    watches[book] = vim.fn.jobstart(cmd, {
      cwd = dir,
      on_exit = function() watches[book] = nil end,
    })
  end
  open_when_ready((book:gsub("%.typ$", ".pdf")), 40)
end

function M.stop()
  local book = M.book()
  if watches[book] then
    vim.fn.jobstop(watches[book])
    vim.notify("stopped watching " .. vim.fs.basename(vim.fs.dirname(book)))
  end
end

-- Chapters are compiled through their book, so tinymist must check them that
-- way too, or every helper defined in book.typ / style.typ shows as an error.
function M.pin_main(client, buf)
  client:exec_cmd({
    title = "Pin main",
    command = "tinymist.pinMain",
    arguments = { M.book(buf) },
  }, { bufnr = buf })
end

return M
