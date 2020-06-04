#!/bin/bash




if [ ! -d "/etc/osbox/ssl" ]; then
    mkdir -p /etc/osbox/ssl/blackbox.surfwijzer.nl
fi

#  get ssl cert
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/osbox-ssl.php

chmod +r  /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.key
chmod +r  /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.ca
chmod +r  /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.cert


cat /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.ca /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.cert > /etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.ca.lighttpd

# install ssl cert

echo "server.modules += ( \"mod_openssl\" )">/etc/lighttpd/external.conf
echo "\$SERVER[\"socket\"] == \"0.0.0.0:443\" {">>/etc/lighttpd/external.conf
echo "    ssl.engine = \"enable\"">>/etc/lighttpd/external.conf
echo "    ssl.openssl.ssl-conf-cmd = (\"Protocol\" => \"-ALL, TLSv1.2, TLSv1.3\") # (recommended to accept only TLSv1.2 and TLSv1.3)">>/etc/lighttpd/external.conf
echo "    ssl.privkey= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.key\"">>/etc/lighttpd/external.conf
echo "    ssl.pemfile= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.cert\"">>/etc/lighttpd/external.conf
echo "    ssl.ca-file= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.ca.lighttpd\"">>/etc/lighttpd/external.conf
echo "}">>/etc/lighttpd/external.conf



echo " ">>/etc/lighttpd/external.conf
echo "\$HTTP[\"host\"] =~ \"^pi\.hole\" {">>/etc/lighttpd/external.conf
echo "    url.redirect = (">>/etc/lighttpd/external.conf
echo "        \"^/(.*)\" => \"https://blackbox.surfwijzer.nl\"">>/etc/lighttpd/external.conf
echo "    )">>/etc/lighttpd/external.conf
echo "}">>/etc/lighttpd/external.conf



echo " ">>/etc/lighttpd/external.conf
echo "\$HTTP[\"host\"] =~ \"blackbox.surfwijzer.nl\" {">>/etc/lighttpd/external.conf
echo "  server.error-handler-404   = \"/index.php/\$1\"">>/etc/lighttpd/external.conf
#echo "  url.rewrite-once = (">>/etc/lighttpd/external.conf
#echo "    \"^/osbox/assets/(?$)\" => \"/osbox/assets/$0\",">>/etc/lighttpd/external.conf
#echo "    \"^/(.+)/?$\" => \"/index.php/$1\"">>/etc/lighttpd/external.conf
#echo "  )">>/etc/lighttpd/external.conf
echo "}">>/etc/lighttpd/external.conf







#$HTTP["host"] =~ "blackbox.surfwijzer.nl" {
#  server.error-handler-404   = "/index.php/$1"
#  url.rewrite-once = (
#    "^/osbox/assets/(?$)" => "/osbox/assets/$0",
#    "^/[^?]*(\?(.*))?$" => "/index.php?$1&full_request=$0",
#    "^/(.*)" => "/index.php/$1"
#  )
#}





echo "blackbox.surfwijzer.nl">/etc/osbox/ssl_enabled


bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_osbox_master.sh



# reload whatever
systemctl restart lighttpd.service
systemctl restart avahi-daemon.service
systemctl restart osbox.service

sleep 2


