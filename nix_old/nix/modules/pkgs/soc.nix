{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        hping
        net-tools
        tcpdump
    ];
}
