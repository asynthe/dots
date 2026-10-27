{ ... }:
{
    flake.modules.nixos.mullvad-tailscale = { ... }: {
        networking.nftables.tables.mullvad-tailscale = {
            family = "inet";
            content = ''
                # Output hook must be -200..0 and input -100..0, or the tunnel IP leaks silently.
                chain output {
                    type route hook output priority 0; policy accept;
                    ip  daddr 100.64.0.0/10       ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                    ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                }

                chain input {
                    type filter hook input priority -100; policy accept;
                    ip  saddr 100.64.0.0/10       ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                    ip6 saddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                }
            '';
        };
    };
}
