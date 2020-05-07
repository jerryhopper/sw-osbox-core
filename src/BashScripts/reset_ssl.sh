#!/bin/bash

echo "">/etc/lighttpd/external.conf

rm -f /etc/osbox/ssl_enabled


systemctl restart osbox.service
systemctl restart lighttpd.service
