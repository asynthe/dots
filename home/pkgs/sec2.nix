{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)

            # -------------- General --------------
            #seclists # Prefer git clone

            # -------------- Active Directory --------------
            responder

            # -------------- Cracking --------------
            hashcat
        ;      
    };
}
