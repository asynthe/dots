# Databases

The SQL learning kit on `p1`: three aspects in `nix/nixos/dev/database.nix`,
plus `vim-dadbod` in the editor. See [ASPECTS.md](ASPECTS.md) for why the
aspects are split the way they are.

## What each tool is for

- `duckdb` — start here. No server, no connection string; it queries CSV and
  Parquet in place (`SELECT * FROM 'file.csv'`). Its dialect is close enough to
  Postgres that the syntax transfers, and it reaches the same files
  `pandas`/`polars` already do in `dev/lang.nix`.
- `psql` — the real target. Window functions, CTEs, `EXPLAIN ANALYZE` and
  constraints that are actually enforced. `postgres-local` runs it on loopback.
- `sqlite` — fine for joins and CRUD, but its typing is advisory. Do not learn
  constraints here; you will learn them wrong.
- `harlequin` — TUI SQL IDE over duckdb, sqlite or postgres. Keyboard-driven,
  results pane, same shape as the rest of this setup.
- `pgcli` / `litecli` — psql and sqlite3 with autocomplete and highlighting.
  The autocomplete is the teaching tool early on; drop to plain `psql` once it
  stops helping.
- `usql` — one client, every backend, when you do not want to remember which
  CLI a given database wants.
- `sqlfluff` — linter and formatter. `sqlfluff fix --dialect postgres`.

## The local server

`postgres-local` creates a `play` database owned by `sys.user`, trusted on
loopback only. Nothing is exposed off the machine.

```bash
psql play                       # or: pgcli play
psql -c '\l'                    # list databases
createdb scratch                # more of them, no auth needed
```

`/var/lib/postgresql` is in the persist list, so it survives the root wipe. A
database is live service state, not archive — see `~/CLAUDE.md`. Anything worth
keeping (schemas, exercises, seed data) is `.sql` in a repo under `~/git/`, not
a file sitting next to the cluster.

## In the editor

`vim-dadbod-ui`, wired to `nvim-cmp` for completion in `sql` buffers.

| Key | Does |
| --- | --- |
| `<leader>du` | Toggle the database drawer |
| `<leader>df` | Jump to a query buffer |
| `<leader>da` | Add a connection |

`vim.g.dbs` in `config/nvim/lua/plugins/database.lua` holds the `play`
connection; add entries there rather than saving connections interactively, so
the list stays in the repo. Saved queries go to `$XDG_DATA_HOME/nvim/db_ui`,
which is scratch — promote the ones worth keeping into a repo.

`db_ui_execute_on_save` is off. `<leader>S` runs the buffer in normal mode and
the selection in visual mode, so writing a file is not a way to accidentally
run a `DELETE`, and visual mode becomes the unit of work: select a CTE, run it,
select the next.

This is also the reason dadbod is worth it over DBeaver day to day — the query
buffer is a normal buffer, so every motion you are drilling applies to it.

## DBeaver

`database-gui`, launched as `dbeaver`. Worth having for browsing an unfamiliar
schema, ER diagrams, and driving a database someone else administers. It is not
where you learn SQL — the connection dialogs outnumber the queries.
