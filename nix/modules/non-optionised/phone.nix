{ pkgs, ... }: {

    users.users.meow.extraGroups = [ "kvm" ];
    #services.gvfs.enable = true;
    environment.systemPackages = with pkgs; [
        jmtpfs
        android-tools
    ];
}
