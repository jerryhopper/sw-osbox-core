#!/bin/bash

source /usr/local/osbox/lib/bashfunc/is_root
source /usr/local/osbox/lib/bashfunc/is_command

# reset avahi to default.

# reset lightttpd config

# remove /etc/pihole/* stuff

# reset systemctl services

if [ -f /etc/osbox/db/osbox.db  ]; then
  rm -f /etc/osbox/db/osbox.db
fi



