# Firefox

Two scripts, cutting the profile along **perpendicular axes**. Knowing which
axis you want is the whole of choosing between them.

| | `firefox_clean.sh` | `firefox_forget.sh` |
| --- | --- | --- |
| cuts by | container | host |
| history | never opened | is the target |
| runs | at login, automatically | by hand, per domain |
| keeps | `^userContextId=N`, `moz-extension+++` | bookmarked pages |

`clean` is the standing policy: the default container is disposable, the named
ones are not. `forget` is the exception you reach for when one site should
leave no trace at all.

## The container split

Firefox tags every cookie row and every site-storage directory with
`originAttributes`. A container's data carries `^userContextId=N`; the default
container's carries nothing. That single tag is what makes "log the unsorted
half out of everything, leave `personal` and `study` signed in" a one-line
`WHERE` clause rather than a per-site chore.

```
''                 ~1500 cookies   default — dropped every login
^userContextId=1     413           personal
^userContextId=6     152           events
^userContextId=4      29           study
^userContextId=7      20           test
```

Extension storage is spared alongside the containers, and not as a courtesy:
Multi-Account Containers keeps its **site → container assignments** in its own
`moz-extension+++` origin. Wiping that destroys the mapping the script exists
to protect — the containers would survive with nothing routed into them.

## Why a login unit and not a timer

`nix/nixos/desktop/firefox.nix` runs the cleaner as a `oneshot` wanted by
`graphical-session-pre.target`, `before` `graphical-session.target`.

The script has to hold the profile alone. Firefox keeps its cookie set in
memory and flushes it back over any outside edit, so a mid-session run either
loses the delete or corrupts `cookies.sqlite`, and pulling `storage/default`
directories out from under open tabs breaks their IndexedDB. A wall-clock timer
cannot promise an idle profile. `graphical-session-pre` provably can — nothing
has launched yet.

`SuccessExitStatus = [ 0 1 ]` because the script exits 1 when Firefox is
already up. That is a skip, not a fault, and must never hold up the session.

## The liveness guard

`pgrep -x firefox` does **not** work on NixOS. The wrapper truncates `comm` to
`.firefox-wrappe`, so an `-x` check cheerfully reports "not running" against a
live browser and the script proceeds to corrupt the profile. Match the real
binary path instead:

```bash
pgrep -f 'lib/firefox/firefox'
```

The profile's `lock` symlink is a second signal — its target encodes the pid as
`127.0.0.2:+PID` — but it survives a crash, so the pid is verified with
`kill -0` rather than the symlink merely existing.

## History, bookmarks and the one row that is both

`places.sqlite` holds history and bookmarks in the same table. A bookmarked page
is a `moz_places` row that `moz_bookmarks` points at, marked by
`foreign_count > 0`. Delete it and the bookmark dangles.

So `forget` splits them: unbookmarked rows go, bookmarked rows stay and are
stripped of their visit record instead.

```sql
UPDATE moz_places SET visit_count = 0, last_visit_date = NULL,
                      frecency = -1, recalc_frecency = 1
      WHERE id IN victims AND foreign_count > 0;
DELETE FROM moz_places
      WHERE id IN victims AND foreign_count = 0;
```

`recalc_frecency = 1` makes Firefox rebuild the ranking rather than trust a
stale number — otherwise a forgotten site keeps its place in the awesomebar.

Six child tables reference `moz_places` and all must go first:
`moz_historyvisits` (and `moz_historyvisits_extra`, keyed on the *visit* id,
not the place), `moz_places_metadata` (twice — `place_id` and
`referrer_place_id`), `moz_inputhistory`, `moz_annos`, `moz_places_extra`.
This schema carries **no triggers**, so `moz_origins` is ours to tidy too.

Hosts are stored reversed with a trailing dot, which is why one pattern covers
a domain and all its subdomains with no `OR`:

```
www.reddit.com  →  moc.tidder.www.        rev_host LIKE 'moc.tidder.%'
```

## Partitioned state

Forgetting a site means more than its own origin. Third-party state loaded
*inside* it is keyed `^partitionKey=%28https%2Creddit.com%29` — Google's cookies
as set on Reddit's pages. `forget --cookies` takes those too, matching with
`instr()` rather than `LIKE`, since those `%` sequences are literal and would
otherwise be wildcards.

## Cookies are not logins

`clean` drops all ~1500 default-container cookies, preferences included. If you
ever want only the sessions, the usable split is the `HttpOnly + Secure` pair —
a session token sets both, and a JS-readable preference or tracking cookie
cannot set the first:

| flags | n | examples |
| --- | --- | --- |
| `httpOnly=1 secure=1` | 397 | `logged_in`, `LOGIN_INFO`, `saved_user_sessions` |
| `httpOnly=0 secure=1` | 397 | `_fbp`, `__ssid`, `XSRF-TOKEN` |
| `httpOnly=0 secure=0` | 714 | `sc_theme`, `edgebucket` |

Saved passwords are a different store entirely and neither script touches it:
`logins.db` + `key4.db` are **profile-wide**, with no container tag. There is
no such thing as a container's password — containers isolate cookies, storage
and cache, and nothing else. The password manager of record is `pass`, in
[AUTH.md](AUTH.md).

## What touches what

| file | what it does |
| --- | --- |
| `scripts/firefox_clean.sh` | by container: cookies, `storage/default`, cache. `--permissions` is opt-in |
| `scripts/firefox_forget.sh` | by host: history always, `--cookies` and `--containers` opt-in |
| `nix/nixos/desktop/firefox.nix` | the `firefox-clean` user unit, and `pkgs.sqlite` on `PATH` |

Both default to a dry run. Both refuse to run while Firefox holds the profile.

```bash
./scripts/firefox_clean.sh                          # what would go
./scripts/firefox_clean.sh --apply
./scripts/firefox_forget.sh reddit.com              # what would go
./scripts/firefox_forget.sh --apply --cookies reddit.com x.com
```

`--permissions` stays off by default because `moz_perms` has no container tag —
every row is global, so there is nothing there to keep for containers, and
clearing it only buys re-prompting for notifications everywhere.
