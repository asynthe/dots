$env.GPG_TTY = (tty)
/nix/store/wwfj0b0mbl9lcnd79xp3r9jxy6ylv2k8-gnupg-2.4.5/bin/gpg-connect-agent updatestartuptty /bye | ignore

$env.SSH_AUTH_SOCK = ($env.SSH_AUTH_SOCK? | default (/nix/store/wwfj0b0mbl9lcnd79xp3r9jxy6ylv2k8-gnupg-2.4.5/bin/gpgconf --list-dirs agent-ssh-socket))

let zoxide_cache = "/home/meow/.cache/zoxide"
if not ($zoxide_cache | path exists) {
  mkdir $zoxide_cache
}
/nix/store/129dfibbfvgp6gwy3wyvmhlis5m2b56f-zoxide-0.9.6/bin/zoxide init nushell  |
  save --force /home/meow/.cache/zoxide/init.nu

let starship_cache = "/home/meow/.cache/starship"
if not ($starship_cache | path exists) {
  mkdir $starship_cache
}
/home/meow/.nix-profile/bin/starship init nu | save --force /home/meow/.cache/starship/init.nu

load-env {}
