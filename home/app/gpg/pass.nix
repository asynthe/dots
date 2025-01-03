{ pkgs, user, ... }: {
    programs.password-store = {
        enable = true;
        package = pkgs.pass-wayland;
        settings = {
            PASSWORD_STORE_DIR = "/home/${user}/sync/pass/pass";
        };
    };
}
