#!/bin/bash

source /usr/local/osbox/lib/bashfunc/is_root
source /usr/local/osbox/lib/bashfunc/is_command




echo "reset avahi to default."
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_osbox_master.sh "reset"

echo " reset lightttpd config"
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/reset_ssl.sh


echo "reset network to default."
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_network_dynamic_ip.sh

# remove /etc/pihole/* stuff

//echo "idle,0,no setup state">/etc/osbox/setup.state
sudo echo "running,10,Preparing files.">/etc/osbox/setup.state

# reset systemctl services
# bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/create_install_service.sh $3
echo "create_install_service.sh"
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/create_install_service.sh sw-osbox-core


if [ -f /etc/osbox/db/osbox.db  ]; then
  rm -f /etc/osbox/db/osbox.db
fi


#reboot
echo "systemctl restart networking"
systemctl restart networking


systemctl restart avahi-daemon.service
echo "systemctl restart avahi-daemon.service"
systemctl restart osbox.service
echo "systemctl restart osbox.service"
systemctl restart osbox-scheduler.service
echo "systemctl restart osbox-scheduler.service"
systemctl restart lighttpd.service

echo "systemctl restart osbox-install.service"
systemctl restart osbox-install.service

