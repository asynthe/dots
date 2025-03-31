{
    services.httpd = {
        enable = true;
	    enablePHP = true;
	    adminAddr = "webmaster@example.org";
	    virtualHosts."html".documentRoot = "/var/www/html";
    };

    systemd.tmpfiles.rules = [
	    "d /var/www/html"
	    "f /var/www/html/index.php - - - - <?php phpinfo();"
    ];
}
