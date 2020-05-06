#!/bin/bash

#  get ssl cert
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/osbox-ssl.php

# install ssl cert


# reload whatever

systemctl restart osbox.service
systemctl restart lighttpd.service


