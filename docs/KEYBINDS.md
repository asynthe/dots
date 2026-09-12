# Neovim keybinds

Leader is `<Space>`.

Neovim owns the whole bare `Ctrl` layer plus `Space`. Hyprland takes `Alt` and
Ghostty takes a single `Ctrl+s` leader, so nothing here is shadowed — their
tables are in the [README](../README.md#keybinds).

Nothing is bound to arrow keys: on the HHKB they need `Fn`, and Ghostty cannot
use `Fn` as a modifier at all.

## Files

| Key            | Action                     |
| -------------- | -------------------------- |
| `<leader><leader>` | Find files             |
| `<leader>e`    | File explorer (oil)        |
| `-`            | Open parent directory      |
| `<leader>,`    | Yazi at current file       |
| `<leader>;`    | Yazi at cwd                |
| `<leader>w`    | Write file                 |
| `<leader>q`    | Quit window                |

## Find (`<leader>f`)

| Key           | Action                  |
| ------------- | ----------------------- |
| `<leader>ff`  | Files                   |
| `<leader>fg`  | Grep project            |
| `<leader>fw`  | Grep word under cursor  |
| `<leader>fb`  | Buffers                 |
| `<leader>fr`  | Recent files            |
| `<leader>fh`  | Help tags               |
| `<leader>fd`  | Document diagnostics    |
| `<leader>fD`  | Workspace diagnostics   |
| `<leader>fm`  | Keymaps                 |
| `<leader>fz`  | Resume last picker      |

## Buffers and windows

| Key           | Action                       |
| ------------- | ---------------------------- |
| `<S-h>`       | Previous buffer              |
| `<S-l>`       | Next buffer                  |
| `<leader>bd`  | Delete buffer                |
| `<leader>bD`  | Delete buffer, discard edits |
| `<C-h/j/k/l>` | Move between windows         |

## Code (`<leader>c`, LSP buffers only)

| Key           | Action                |
| ------------- | --------------------- |
| `gd`          | Goto definition       |
| `gD`          | Goto declaration      |
| `gI`          | Goto implementation   |
| `gY`          | Goto type definition  |
| `K`           | Hover docs            |
| `grr`         | References (built-in) |
| `grn`         | Rename (built-in)     |
| `<leader>cr`  | Rename symbol         |
| `<leader>ca`  | Code action           |
| `<leader>cf`  | Format buffer         |
| `<leader>cs`  | Document symbols      |
| `<leader>cS`  | Workspace symbols     |
| `<leader>cd`  | Line diagnostics      |
| `[d` / `]d`   | Prev / next diagnostic |
| `[f` / `]f`   | Prev / next function  |
| `af` / `if`   | Function textobject   |
| `ac` / `ic`   | Class textobject      |
| `aa` / `ia`   | Parameter textobject  |
| `<CR>`        | Expand selection      |
| `<BS>`        | Shrink selection      |

## Git (`<leader>g`, tracked files only)

| Key           | Action              |
| ------------- | ------------------- |
| `]h` / `[h`   | Next / prev hunk    |
| `<leader>gs`  | Stage hunk          |
| `<leader>gr`  | Reset hunk          |
| `<leader>gp`  | Preview hunk        |
| `<leader>gb`  | Blame line          |
| `<leader>gB`  | Blame buffer        |
| `<leader>gd`  | Diff this file      |

## Notes (`<leader>n`)

| Key           | Action                 |
| ------------- | ---------------------- |
| `<leader>.`   | Open note by title     |
| `<leader>nn`  | New note               |
| `<leader>nm`  | Open `main.md`         |
| `<leader>nt`  | Today's daily note     |
| `<leader>ny`  | Yesterday's daily note |
| `<leader>ns`  | Search notes           |
| `<leader>nq`  | Quick switch note      |
| `<leader>nb`  | Backlinks              |
| `<leader>nl`  | Links in note          |
| `<leader>no`  | Table of contents      |
| `<leader>nx`  | Toggle checkbox        |
| `<leader>np`  | Paste image            |
| `<leader>nr`  | Rename note            |
| `<leader>mp`  | Markdown preview       |

In markdown buffers:

| Key       | Action                             |
| --------- | ---------------------------------- |
| `<C-CR>`  | New list item, same marker         |
| `<C-t>`   | Indent line (insert mode, builtin) |
| `<C-d>`   | Dedent line (insert mode, builtin) |
| `>>` / `<<` | Indent / dedent (normal mode)    |

## UI toggles (`<leader>u`)

| Key           | Action                 |
| ------------- | ---------------------- |
| `<leader>us`  | Statusline             |
| `<leader>uw`  | Wrap                   |
| `<leader>un`  | Line numbers           |
| `<leader>ur`  | Relative numbers       |
| `<leader>uc`  | Conceal                |
| `<leader>ud`  | Diagnostics            |
| `<leader>uf`  | Format on save         |

## Editing

| Key         | Action                    |
| ----------- | ------------------------- |
| `<Esc>`     | Clear search highlight    |
| `J` / `K`   | Move selection (visual)   |
| `<` / `>`   | Indent, keep selection    |
| `<C-d>`     | Half page down, centred   |
| `<C-u>`     | Half page up, centred     |
| `n` / `N`   | Next / prev match, centred |
| `ga` / `gA` | Align (mini.align)        |

Press `<leader>?` for buffer-local keys, or `<leader>fm` to search every map.

## Deliberately left alone

`.` (repeat), `<Tab>` / `<C-i>` (jumplist forward), `<C-]>` (tag jump, help
links), `<C-o>` (jumplist back), `<C-w>` (window prefix), `<C-t>`, `<C-\>` and
the `gr*` prefix are Neovim built-ins that earlier versions of this config, or
Ghostty, had shadowed.
