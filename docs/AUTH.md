# Accounts

`auth.nix` at the repo root is the entire user list. It is plain data rather
than a module: it sits outside `nix/` precisely so import-tree ignores it, and
`nix/nixos/base/auth.nix` is the aspect that reads it and turns it into
accounts. Nothing else in the repo declares a user, and the file does not move
under `nix/` — that is what would make it a module.

Same file and same aspect as [`flakes`](https://gitlab.com/asynthe/flakes),
which is what makes an account portable between the laptop and `sarten` — copy
the entry across, add its hash to that repo's `secrets/secrets.yaml`, done.

```nix
{
    meow = {
        admin       = true;
        passwordKey = "users/meow";
        keys = [
            "ssh-ed25519 AAAA... s24"
        ];
    };
}
```

Four fields, all optional, all defaulting to the least privilege. `keys` is the
list of ssh public keys and defaults to empty — an account with no keys is
created but cannot log in over the network at all. `passwordKey` names where
that user's login hash lives inside `secrets/secrets.yaml` and **defaults to
`null`**, which locks the password: key-only ssh keeps working and `sudo` does
not. `groups` is extra service groups for a user who is not an admin. `admin`
defaults to `false`, and turning it on does two separate things — it puts the
account in `wheel`, and it makes it a nix daemon trusted-user. Both amount to
root on the machine.

Because those two are separate powers, an admin without a password is a silent
contradiction: `wheel` needs a password, so `sudo` could never succeed, while
`trusted-users` hands out root through the daemon anyway with no password
involved. An assertion rejects that combination outright — an `admin` must name
a `passwordKey`.

Admins also get every group an aspect hands out — `audio`, `networkmanager`,
`input`, `kvm`, `adbusers`, `tss`, `wireshark`, `libvirtd`, `incus-admin`,
`hermes`. That is why no aspect names a user: they all write to
`lib.genAttrs config.sys.admins`, which `auth.nix` populates. A non-admin gets
none of them, which is what the `groups` field is for.

## The seat

`sys.user` is the one thing `auth.nix` does not answer: which account is
physically sitting at this machine. It is what `getty` autologins into, it
defaults to the first admin, and an assertion requires it to be an account
`auth.nix` declares. That is its only remaining job — group membership and
passwords no longer go through it.

## Ssh

Password authentication is derived, not configured: the `ssh` aspect turns it
off as soon as any admin has a key, so **the first key added to `auth.nix` is
what closes the door**, not a setting someone has to remember. Root login is off
unconditionally. Passwords in this repo are therefore never login credentials —
they exist for the physical console, for `su`, and to satisfy `wheel`.

## Adding a key

Public halves only — `keys` is a list of `ssh-ed25519 AAAA... <label>` lines,
one per client *device*, labelled with the device so a lost laptop is one line
to delete. The private halves live in `~/git/auth`, encrypted.

A key goes in the `auth.nix` of the host it *enters*, not the host it lives on.
`p1`'s own key belongs in `~/git/flakes/auth.nix`, which is what lets this
laptop reach `sarten`; putting it here would only authorise `p1` to ssh to
itself. It becomes useful the day this repo has a second host.

**Do not reuse a key that is already a credential somewhere else** — the GitHub
key is the usual mistake. One private key that both pushes to GitHub and opens
a machine makes a single theft into both.

Adding a key to an entry is the whole job: `nixos-rebuild switch` and the key
is live. Nothing else needs editing, and the account is already there.

## Adding a user

An account with no `admin` and no `passwordKey` is a guest: it can ssh in with
its key, it cannot `sudo`, and its password is locked so the console and `su`
refuse it too.

```nix
friend = {
    keys   = [ "ssh-ed25519 AAAA... friend-laptop" ];
    groups = [ "media" ];
};
```

That is the entire change — no hash, no sops, nothing outside `auth.nix`. Give
it `groups` only where you mean it; an empty list is a shell and a home
directory and nothing else. `/home` is its own btrfs subvolume, so the account's
home survives the impermanence rollback without any extra declaration.

An **admin** needs one more step, because `wheel` requires a password:

```bash
mkpasswd -m yescrypt          # paste the output into the editor below
sops secrets/secrets.yaml     # add it under `users:` as <name>: <hash>
```

Then set `admin = true; passwordKey = "users/<name>";` and rebuild. The secret
is `neededForUsers`, so it is decrypted during the `users` activation step,
early enough to set `hashedPasswordFile` — see [SECRETS.md](SECRETS.md).

## A transfer account

`kazu` is the worked example: someone who should be able to move files on and
off this machine and do nothing else.

```nix
kazu = {
    groups = [ "share" ];
    keys   = [ "ssh-rsa AAAA... kazu" ];
};
```

No `admin`, no `passwordKey`, so: not in `wheel`, not a nix trusted-user, and
the password is locked — key-only, and `sudo` and `su` are closed. The whole
grant is one group.

**He gets his own home, and that is the right answer.** A home is a directory,
not a privilege, and sftp needs somewhere to land. Pointing a second account at
`/home/meow` looks tidy and is not: `/home/meow` is mode 700 and owned by
`meow`, so the guest cannot write to what is nominally his own home, sftp opens
in a directory he cannot use, and the only way to fix it — loosening the mode —
hands him `~/.ssh`, `~/git/auth` and every key on the machine. Two accounts
sharing a home is one account with two keys.

What is shared is a directory instead, mounted where he lands.

## Publishing a directory to a user

`sys.share.mounts` maps a mountpoint to a source:

```nix
sys.share.mounts."/home/kazu/music" = "/home/meow/archive/media/music";
```

`/home/kazu/music` and `~/archive/media/music` are then the same directory —
one copy, no sync, no second 556G. He logs in, `cd music`, and he is in the
library; either side sees the other's writes immediately.

**It has to be a bind mount, not a symlink.** A symlink is resolved on every
access, so opening `/home/kazu/music/album` would walk
`/home/meow` → `archive` → `media`, and `/home/meow` is `drwx------`. Making
that work means granting traverse on the home directory, and on this machine
that single mode bit is the only thing protecting it: `~/ben`, `~/git` and
`~/.config` are all `0755` underneath. A bind mount is resolved once, at mount
time, so reaching the music never walks those parents and nothing else in the
home is reachable by any path.

Write access comes from the `share` group, which the aspect declares as an ACL
on the source. Admins are in the group by default (`sys.share.members`);
everyone else joins with `groups = [ "share" ]` in `auth.nix`. The aspect is
what creates the group, so a host importing `auth` with a `share` member must
import `share` too.

A mount is read-write by default. The long form makes one read-only:

```nix
sys.share.mounts = {
    "/home/kazu/music" = "/home/meow/archive/media/music";
    "/home/kazu/roms"  = { source = "/home/meow/archive/roms"; writable = false; };
};
```

"Read-only" here is a permission, not a mount flag: everything under `~/archive`
is already `0755`, so reading needs no grant at all, and `writable = false`
simply means the source is not opened to the `share` group. He can read it and
cannot change or delete anything in it. Nothing has to be run afterwards either
— the `setfacl` below is only for the writable ones.

To publish another directory, add another entry. To stop publishing one, delete
it — the data does not move either way.

### Making it writable

Reading already works: everything under `~/archive` is `0755`. Writing needs
the `share` group on the files, which the aspect declares as an ACL on the
bind's source — but systemd-tmpfiles applies it to the directory itself, which
covers the directory and everything created in it afterwards, not the 556G
already there. That part is one command, once:

```bash
setfacl -R -m g:share:rwX -m d:g:share:rwX ~/archive/media/music
```

Check it took with `getfacl ~/archive/media/music | grep share`. Until it runs,
`kazu` can read the existing library and add to it, but not modify or delete
what is already there — which may well be what you want.

It is metadata only, so it runs at the speed of the inode count rather than the
size: `~/archive/roms` is 532G in 671 files and finishes instantly, while
`~/archive/games` is 474G in 292,613 and takes a while. Do the writable sources
in one pass:

```bash
for d in media/music media/anime media/book media/movies media/series \
         media/youtube arcade games roms windows; do
    setfacl -R -m g:share:rwX -m d:g:share:rwX ~/archive/$d
done
```

### If a shell is too much

This account has a real shell — that is what makes `rsync` work, since `rsync`
execs itself through the login shell on the far side. `scp` and `sftp` do not
need one. To take the shell away:

```nix
services.openssh.extraConfig = ''
    Match User kazu
        ForceCommand internal-sftp
        ChrootDirectory /home/kazu
        AllowTcpForwarding no
'';
```

`ChrootDirectory` requires the directory to be owned by root and not
group-writable, so the jail would be `/home/kazu`, owned by
root, with the writable `music/` mounted inside it. NixOS renders `extraConfig` at the end of
`sshd_config`, after the `HostKey` lines, so a `Match` block there is safe —
but it must stay last, since everything after it belongs to the match.

That costs `rsync`, which execs itself through the login shell on the far side.
`rrsync` (in nixpkgs, `pkgs.rrsync`) is the way to keep it: a wrapper that
accepts only rsync's own server invocation and only under one directory.
`ForceCommand ${pkgs.rrsync}/bin/rrsync -wo /home/kazu/music` in the match, or
per key, which restricts one device rather than the whole account:

```
command="/nix/store/…/bin/rrsync -wo /home/kazu/music",restrict ssh-ed25519 AAAA… kazu
```

`restrict` turns off the pty, port, agent and X11 forwarding in one word. The
store path is the catch — `auth.nix` is plain data with no `pkgs` in scope, so
a line like that has to be assembled by the aspect, not written by hand.

## Who can reach sshd

`services.openssh.openFirewall` is on, so port 22 is open on **every**
interface, not only `tailscale0` — including whatever network the laptop joins
next. A guest account is therefore reachable from any café wifi, not just from
the tailnet. Setting `openFirewall = false` in the `ssh` aspect leaves ssh
working over the tailnet, since `tailscale0` is a trusted interface, and closes
it everywhere else.

## Removing someone

Delete the entry. The account, its keys and its groups go with the next
rebuild, and the `users/<name>` leaf in `secrets.yaml` can go too. NixOS does
not delete the home directory — `/home/<name>` stays until you remove it by
hand.
