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

## Database (`<leader>d`)

| Key           | Action                 |
| ------------- | ---------------------- |
| `<leader>du`  | Toggle database drawer |
| `<leader>df`  | Find query buffer      |
| `<leader>da`  | Add connection         |
| `<leader>S`   | Run query (sql buffers)|

`<leader>S` is buffer-local to `sql`; normal mode runs the buffer, visual mode
runs the selection. See [DATABASE.md](DATABASE.md).

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
| `<leader>up`  | Motion hints           |
| `<leader>uP`  | Peek motion hints once |

## Textobjects (mini.ai)

`a` is "around", `i` is "inside". Every one works with any operator: `d`, `c`,
`y`, `v`, `=`. Available in any parsed buffer, not just LSP ones.

| Key           | Action                 |
| ------------- | ---------------------- |
| `af` / `if`   | Function (treesitter)  |
| `ac` / `ic`   | Class (treesitter)     |
| `aa` / `ia`   | Parameter (treesitter) |
| `a(` `a[` `a{` | Bracket pair          |
| `a"` `a'` `` a` `` | Quoted string     |
| `at` / `it`   | Tag                    |
| `aq` / `iq`   | Any quote              |
| `ab` / `ib`   | Any bracket            |
| `a?` / `i?`   | Prompt for delimiters  |

`f`, `c` and `a` are routed through treesitter so they mean the same thing they
did when nvim-treesitter-textobjects owned them. mini.ai maps `a` and `i` as
operator-pending prefixes, which shadows every other `a*`/`i*` mapping — that
is why the `select` block is gone from `treesitter.lua` rather than sitting
there dead.

Counts and directions work: `2if` is the second function inside, `in(` the next
bracket, `il(` the previous one. `an` / `in` shadow the textobjects Neovim
0.12 added under the same keys; mini.ai does this on purpose and the version
here is a superset.

## Surround (mini.surround)

| Key    | Action                                    |
| ------ | ----------------------------------------- |
| `sa`   | Add surrounding (visual, or with a motion) |
| `sd`   | Delete surrounding                        |
| `sr`   | Replace surrounding                       |
| `sf` / `sF` | Find surrounding right / left        |
| `sh`   | Highlight surrounding                     |

`saiw"` quotes a word, `sd"` unquotes it, `sr"'` swaps the quote style. Shadows
builtin `s`, which was only ever `cl`.

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
| `s`         | Surround prefix (mini.surround) |

Press `<leader>?` for buffer-local keys, or `<leader>fm` to search every map.

## Deliberately left alone

`.` (repeat), `<Tab>` / `<C-i>` (jumplist forward), `<C-]>` (tag jump, help
links), `<C-o>` (jumplist back), `<C-w>` (window prefix), `<C-t>`, `<C-\>` and
the `gr*` prefix are Neovim built-ins that earlier versions of this config, or
Ghostty, had shadowed.
