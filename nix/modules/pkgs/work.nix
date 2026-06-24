{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [ 
        code-cursor
        kanri
        postman 
    ];
}
