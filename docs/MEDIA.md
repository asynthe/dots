# The media stack

Three aspects on `sarten`, in `nix/nixos/server/`: `jellyfin.nix` serves the
library, `arr.nix` runs Radarr, Sonarr, Lidarr, Prowlarr and Bazarr and builds
the by-director tree, `qbittorrent.nix` is the download client. Jellyfin is
documented first because it is the oldest and its traps are the ones that bite
on a rebuild; the acquisition side starts at [The arr stack](#the-arr-stack).

## `jellyfin`

Defined in `nix/nixos/server/jellyfin.nix`. Imported by `sarten` only — `p1`
dropped it once the laptop running a second media server on the same port
started shadowing ssh forwards to the real one.

### Options

| option | default | notes |
| --- | --- | --- |
| `sys.jellyfin.mediaDir` | `/srv/media` | library root, `0775 jellyfin:jellyfin` |
| `sys.jellyfin.openFirewall` | `false` | opens 8096/8920 to the LAN |

`sys.user` is added to the `jellyfin` group so you can drop files into the
library without sudo. Log out and back in after the first switch.

### Impermanence is the trap

`/` is the `root` btrfs subvolume and gets rolled back to blank on every boot,
so a library at `/srv/media` would vanish nightly. The aspect persists
`mediaDir` along with `/var/lib/jellyfin` and `/var/cache/jellyfin`, all guarded
by `sys.impermanence.enable` so the same code is inert on a host that never
turns it on.

`/home` and `/persist` are separate subvolumes and survive independently — media
under `/home` would persist on its own, but jellyfin runs as its own user and
would need the home directory loosened to read it. A persisted `/srv/media` with
group write is the cleaner trade.

#### Persisted directories need explicit ownership

`environment.persistence` defaults every entry to `root:root 0755`. A bind mount
shadows whatever `systemd.tmpfiles` would have set, so declaring the directory as
a bare string hands jellyfin a state dir it cannot write — it aborts on
`UnauthorizedAccessException` at `/var/lib/jellyfin/log` before logging anything
useful. Each entry therefore carries its own `user`/`group`/`mode`:

```nix
{ directory = "/var/lib/jellyfin"; user = "jellyfin"; group = "jellyfin"; mode = "0700"; }
```

`create-directories.bash` only applies that on *first* creation; afterwards it
copies ownership from the `/persist` source onto the mount point. A directory
already created wrong stays wrong until it is chowned by hand. Bind mounts share
the inode, so chowning either side fixes both.

### Reaching it

`openFirewall` stays off. The `tailscale` aspect puts `tailscale0` in
`networking.firewall.trustedInterfaces`, so the server answers on the tailnet
already; locally it is `http://localhost:8096`. Turn `openFirewall` on only to
serve devices on the LAN that are not on the tailnet.

### Transcoding

`services.jellyfin.hardwareAcceleration` is available and unset. Enabling it
needs the right render node — on a hybrid-graphics host `/dev/dri/renderD128`
may be either the Intel iGPU or the discrete card depending on enumeration
order, so check with `ls -l /dev/dri/by-path` before wiring it up. Direct play
needs none of this.

## The arr stack

`nix/nixos/server/arr.nix` defines the `arr` aspect: Radarr (movies), Sonarr
(series and anime), Lidarr (music), Prowlarr (indexers) and Bazarr (subtitles).
`nix/nixos/server/qbittorrent.nix` defines `qbittorrent`, the download client
they hand grabs to. Both are imported by `sarten` only.

| service | port | user | notes |
| --- | --- | --- | --- |
| radarr | 7878 | `radarr:media` | movies, one flat root folder |
| sonarr | 8989 | `sonarr:media` | series *and* anime, two root folders |
| lidarr | 8686 | `lidarr:media` | music |
| prowlarr | 9696 | `DynamicUser` | indexers only, never touches the library |
| bazarr | 6767 | `bazarr:media` | writes subtitles beside the video files |
| qbittorrent | 8080 | `qbittorrent:media` | web UI; peers come in on 6881 |

### Options

| option | default | notes |
| --- | --- | --- |
| `sys.arr.mediaDir` | `/srv/media` | must match `sys.jellyfin.mediaDir` |
| `sys.arr.group` | `media` | shared primary group, see below |
| `sys.arr.bind` | `127.0.0.1` | every arr UI except Bazarr's |
| `sys.arr.directorTag` | `dir-` | Radarr tag prefix that means "group this one" |
| `sys.arr.directorNames` | `{}` | folder names title-casing gets wrong |
| `sys.arr.syncInterval` | `15min` | fallback reconcile, on top of the path watch |
| `sys.arr.openFirewall` | `false` | opens all five UI ports to the LAN |
| `sys.qbittorrent.downloadDir` | `/srv/media/downloads` | same filesystem as the root folders |
| `sys.qbittorrent.group` | `media` | must match `sys.arr.group` |
| `sys.qbittorrent.bind` | `127.0.0.1` | web UI address |
| `sys.qbittorrent.webuiPort` | `8080` | |
| `sys.qbittorrent.torrentPort` | `6881` | |
| `sys.qbittorrent.openTorrentPort` | `false` | needs a router forward to mean anything |
| `sys.qbittorrent.openFirewall` | `false` | opens the web UI to the LAN |

`mediaDir` is declared twice — once here, once in `jellyfin.nix` — because the
two aspects are independent and neither should fail to evaluate without the
other. Both default to `/srv/media`, so there is nothing to set; if you move the
library you must move both.

### Layout

One ZFS dataset, `tank/media`, holds all of it:

```
/srv/media/                     jellyfin:jellyfin 0775
├── downloads/                  qbittorrent, one directory per category
│   ├── movies/  series/  anime/  music/
├── movies/                     radarr root folder — flat, radarr owns it
├── series/                     sonarr root folder
├── anime/                      sonarr root folder, series type "anime"
├── music/                      lidarr root folder
├── book/  youtube/             not arr-managed
└── library/movies/             generated; the only movie path jellyfin scans
    ├── Directors/<Name>/<Movie (Year)>  →  ../../../../movies/...
    └── General/<Movie (Year)>           →  ../../../movies/...
```

Point Jellyfin's libraries at `library/movies`, `series`, `anime` and `music` —
never at `/srv/media` itself, which would make it scan `downloads/` and index
half-finished files, and index every movie twice.

### Downloads live under the media root on purpose

It looks untidy and it is deliberate. Radarr and Sonarr import by hardlink: the
file stays in `downloads/` for the torrent to keep seeding while a second name
for the same inode appears in `movies/`, costing no space and taking no time. A
hardlink cannot cross a filesystem. A separate `tank/downloads` dataset is a
separate filesystem, so it would turn every import into a full copy — twice the
space, and a long stall on a large file — without ever reporting an error.

`zfs list` is how you catch this. If `tank/downloads` exists, the layout is wrong.

### The director problem

Radarr has no `{director}` token in its folder format, and the reason is deeper
than a missing feature: Radarr stores no crew at all. It is not in the database
and not in `/api/v3/movie`, so no amount of renaming or NFO writing can produce
a director folder.

So the tree is not derived, it is curated. Create a tag `dir-denis-villeneuve`
in Radarr, apply it to the movies you want grouped, and `arr-library.service`
builds `Directors/Denis Villeneuve/` out of symlinks to Radarr's flat folder.
Anything untagged lands in `General/`. Tags are prettified by title-casing the
slug, which is right for most names and wrong for a few — those go in
`sys.arr.directorNames`:

```nix
sys.arr.directorNames = { "wong-kar-wai" = "Wong Kar-wai"; };
```

A movie with two director tags appears under both. A tag without the `dir-`
prefix is ignored, so tags you already use for quality or restrictions are safe.

The unit reconciles rather than rebuilds — it removes only the symlinks that no
longer match and creates only the ones missing — because a tree that churns on
every run makes Jellyfin rescan on every run. An emptied `Directors/<Name>` is
pruned; `Directors` and `General` themselves are tmpfiles' job and are left
alone.

It is triggered two ways. `arr-library.path` watches `movies/` and fires within
seconds of an import or a rename, which covers everything that touches disk. A
tag added in the Radarr UI touches nothing on disk, so `arr-library.timer` sweeps
every 15 minutes as well. To see it now:

```sh
systemctl start arr-library && journalctl -u arr-library -n 20
```

#### No API key to manage

The unit runs as `radarr` and reads the key out of
`/var/lib/radarr/.config/Radarr/config.xml`, which Radarr writes itself on first
start. Nothing goes in sops, and there is no chicken-and-egg on a fresh install
beyond "start Radarr once". Before that first start the unit exits with `no
ApiKey in radarr's config.xml yet`, which is expected, not a failure to chase.

### One group, and why it is the primary one

Five services write to the same tree, so they share a group: `media`. It is set
as each service's **primary** group rather than a supplementary one, on purpose.
The nixpkgs servarr units run with `PrivateUsers=true`, which maps only the
service's own uid and gid into its user namespace — a supplementary group is the
kind of thing that stops working under it in ways that surface as a permission
error three layers into an import log. A primary gid is always mapped.

The two halves of that are the setgid bit and the umask. Every library directory
is `2775 root:media`, so a file created in it inherits the group whichever
service made it, and the arrs and qBittorrent run with `UMask=0002` so the group
keeps write access. The servarr modules hardcode `0022`, which strips it, so the
aspect overrides them with `lib.mkForce`.

Jellyfin is deliberately *not* in the group. It only reads, and every directory
is `o+rx` with every file `o+r`, so it needs nothing. That keeps it running as
`jellyfin:jellyfin` and keeps its own `PrivateUsers=true` out of the question.

`sys.user` is in `media`, so you can drop files in without sudo. Log out and back
in after the first switch.

### Reaching them

Every UI binds `127.0.0.1` and no firewall port is opened, same as Grafana and
the Incus UI:

```sh
ssh -L 7878:localhost:7878 -L 8989:localhost:8989 -L 9696:localhost:9696 \
    -L 8686:localhost:8686 -L 6767:localhost:6767 -L 8080:localhost:8080 sarten
```

Two exceptions worth knowing. **Bazarr has no bind option** — it reads its
address from its own `config.ini` and listens on every interface until told
otherwise. And `tailscale0` is in `networking.firewall.trustedInterfaces`, so
anything bound to a wildcard address is reachable by every device on your
tailnet. Neither is a hole in the LAN, but neither is loopback either. Confirm
what is actually listening rather than trusting the option:

```sh
ss -ltnp | grep -E '7878|8989|8686|9696|6767|8080'
```

### qBittorrent has no password

`WebUI\LocalHostAuth=false`, so a request from loopback is not challenged. The
alternative is a PBKDF2 hash in sops plus the same secret configured in three
arrs; the boundary that actually matters here is the firewall, which opens port
22 and nothing else. Anything that can reach the UI already has ssh.

If you ever open `openFirewall`, this stops being true. Set a password first.

#### Four settings come from Nix and are lost if you change them in the UI

The nixpkgs module reinstalls `qBittorrent.conf` from the store on **every**
start, so the save path, the torrent port, the web UI address and port, and
`LocalHostAuth` are whatever `qbittorrent.nix` says — edit them in the UI and the
next restart reverts them. Everything the aspect does *not* declare — speed
limits, seeding ratios, scheduling — is left to the UI and survives.

Categories are the exception on purpose. qBittorrent rewrites `categories.json`
itself whenever you edit a category, so tmpfiles seeds it with a `C` line, which
copies only when the file is absent. The four seeded categories (`radarr`,
`sonarr`, `sonarr-anime`, `lidarr`) match what you set on each arr's download
client, and are yours to change afterwards.

### Incoming peers

`openTorrentPort` opens 6881 on the host, which on its own does nothing: peers
arrive from the internet, so it also needs a forward on the router at
192.168.1.1 to 192.168.1.135:6881. Outgoing connections work without either, so
the stack functions untouched — you just get fewer peers. There is no VPN in
front of qBittorrent; `mullvad` is a `p1` aspect and is not imported here.

## Anime

Anime is a Sonarr concern, not a separate application. Add `/srv/media/anime` as
a second root folder and set the series type to **Anime** when adding a show —
that switches Sonarr to absolute episode numbering, which is how fansub releases
are named and the single most common reason an anime release will not match.

Keep it as its own Jellyfin library rather than mixing it into series. Jellyfin
has no anime type, so a separate library is the only thing that keeps season
ordering and artwork sane.

## Bringing up the stack

Order matters, because each app configures the one before it.

```sh
# 1. Deploy from p1.
nh os switch /home/meow/dots -H sarten -- --target-host sarten

# 2. The three existing movies are meow:users. Nothing else is, and the arrs
#    cannot rename what they cannot write.
ssh sarten 'sudo chgrp -R media /srv/media && sudo chmod -R g+w /srv/media'

# 3. `tv/` was an empty duplicate of `series/`. Confirm, then drop it.
ssh sarten 'find /srv/media/tv | head; rmdir /srv/media/tv'
```

Then, over the ssh forwards above, in this order:

1. **Prowlarr** (9696) — finish the auth wizard, add indexers, then add Radarr,
   Sonarr and Lidarr as *Apps* so it pushes indexers into all three.
2. **qBittorrent** (8080) — nothing to do; confirm the four categories are
   present and the save path is `/srv/media/downloads`.
3. **Radarr** (7878) — root folder `/srv/media/movies`; download client
   qBittorrent at `127.0.0.1:8080`, no credentials, category `radarr`; then
   *Library Import* to adopt the three movies already on disk.
4. **Sonarr** (8989) — two root folders, `/srv/media/series` and
   `/srv/media/anime`; same download client, categories `sonarr` and
   `sonarr-anime`.
5. **Lidarr** (8686) — root folder `/srv/media/music`, category `lidarr`.
6. **Bazarr** (6767) — connect to Radarr and Sonarr, pick subtitle providers.
7. **Jellyfin** (8096) — add the four libraries from [Layout](#layout).

Each arr shows a first-run auth wizard. Nothing in the aspect sets
`AuthenticationMethod`, so pick one there: **Forms** with a password, or
*Disabled for Local Addresses* given these are loopback-only. The servarr
project documents `RADARR__AUTH__*` environment variables for doing this
declaratively through `services.radarr.settings`, but the exact keys were not
verified against this nixpkgs, so it is a wizard step until someone checks.

### Verifying it worked

```sh
systemctl status radarr sonarr lidarr prowlarr bazarr qbittorrent
systemctl start arr-library && journalctl -u arr-library -n 20

# Hardlinks, not copies: an imported movie has a link count above 1.
stat -c '%h %n' /srv/media/movies/*/*.mkv

# One dataset, no accidental tank/downloads.
zfs list -r tank
```
