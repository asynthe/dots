{ pkgs, ... }: {

  home.packages = builtins.attrValues {
    inherit (pkgs)

      # Where to put this
      #qgis #qgis-ltr

      # Download / torrent
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      wirelesstools # Maybe replace in future?
      #socat # replacement of openbsd-netcat
      bc
      nethogs
      mtr # A network diagnostic tool
      iperf3
      dnsutils # `dig` + `nslookup`
      ldns # replacement of `dig`, it provide the command `drill`
      ipcalc # it is a calculator for the IPv4/v6 addresses
      #inetutils
      dnsmasq
      traceroute
      networkmanagerapplet
      filezilla
      dig
      netcat-openbsd #netcat #netcat-gnu
      socat #websocat
      putty
      openvpn3 #openvpn
      ;
  };
}
