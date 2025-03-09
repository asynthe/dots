{ pkgs, ... }: {

    services.picom = {
        enable = true;
        package = pkgs.picom-pijulius;
        #settings = {
            # ...
        #};
    };
}
