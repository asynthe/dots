{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [

        # System
        ethtool
        iftop # Network monitoring
        inxi
        iotop # IO monitoring
        lm_sensors # for `sensors` command
        lshw # List hardware details
        lsof # List open files
        ltrace # Library call monitoring
        parted
        pciutils # lspci
        powershell
        strace # System call monitoring
        sysstat
        usbutils # lsusb

        # Networking
        nethogs
        mtr # A network diagnostic tool
        iperf3
        dnsutils # `dig` + `nslookup`
        ldns # replacement of `dig`, it provide the command `drill`
        ipcalc # it is a calculator for the IPv4/v6 addresses
        #inetutils
        dnsmasq
        traceroute
        filezilla
        dig
        netcat-openbsd #netcat #netcat-gnu
        socat #websocat
        putty
    ];
}
