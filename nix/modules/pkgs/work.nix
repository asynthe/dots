{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [ 
        postman 
        code-cursor
    ];
}
