#!/bin/bash

#  get ssl cert
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/osbox-ssl.php

# install ssl cert

echo "server.modules += ("mod_openssl")">/etc/lighttpd/external.conf
echo "\$SERVER[\"socket\"] == \"0.0.0.0:443\" {">>/etc/lighttpd/external.conf
echo "    ssl.engine = \"enable\"">>/etc/lighttpd/external.conf
echo "    ssl.openssl.ssl-conf-cmd = (\"Protocol\" => \"-ALL, TLSv1.2, TLSv1.3\") # (recommended to accept only TLSv1.2 and TLSv1.3)">>/etc/lighttpd/external.conf
echo "    ssl.privkey= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.key\"">>/etc/lighttpd/external.conf
echo "    ssl.pemfile= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.cert\"">>/etc/lighttpd/external.conf
echo "    ssl.ca-file= \"/etc/osbox/ssl/blackbox.surfwijzer.nl/ssl.ca\"">>/etc/lighttpd/external.conf
echo "}"



# reload whatever

systemctl restart osbox.service
systemctl restart lighttpd.service


