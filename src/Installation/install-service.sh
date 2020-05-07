#!/bin/bash


set -e


echo "heartbeat" > /sys/class/leds/nanopi:red:pwr/trigger


sudo echo "running,10,Preparing files.">/etc/osbox/setup.state

bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_ftl.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_blocklists.sh
#bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_setupvars.sh

sleep 2

sudo echo "running,10,Installing requirements">/etc/osbox/setup.state


apt-get -y install php-common php-sqlite3 php-xml php-intl php-zip php-mbstring php-gd php-apcu php-cgi composer dialog dhcpcd5 dnsutils lsof nmap netcat idn2 dns-root-data composer

sudo echo "running,10,Installing services (this may take a while)">/etc/osbox/setup.state

wget https://raw.githubusercontent.com/pi-hole/pi-hole/master/automated%20install/basic-install.sh
bash ./basic-install.sh --unattended


sudo echo "running,10,Upgrading release">/etc/osbox/setup.state

# Set repo to V5 beta
echo "release/v5.0" | sudo tee /etc/pihole/ftlbranch
echo "yes"|pihole checkout core release/v5.0
echo "yes"|pihole checkout web release/v5.0


sudo echo "running,10,Preparing files.">/etc/osbox/setup.state

bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_ftl.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_blocklists.sh
#bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_setupvars.sh
sleep 1


# get osbox-core-web
if [ -d "/usr/local/osbox/project/sw-osbox-core-web" ]; then
    rm -rf /usr/local/osbox/project/sw-osbox-core-web
fi
sudo echo "running,10,Installing blackbox web.">/etc/osbox/setup.state
git clone https://github.com/jerryhopper/sw-osbox-core-web.git /usr/local/osbox/project/sw-osbox-core-web




IP="$(osbox network info|awk -F ',' '{print $1}')"
NETTYPE="$(osbox network info|awk -F ',' '{print $2}')"

echo "NETTYPE='$NETTYPE'"

if [ "$NETTYPE" == "STATIC" ];then

  echo "$IP nonexistent.surfwijzer.nl" > /etc/pihole/custom.list
  echo "$IP blackbox.surfwijzer.nl" >> /etc/pihole/custom.list

  echo "$IP osbox" > /etc/pihole/local.list
  echo "$IP pi.hole" >> /etc/pihole/local.list

  echo "<?php include(\"/usr/local/osbox/project/sw-osbox-core-web/src/index.php\");" > /var/www/html/index.php
  chown -R +r /usr/local/osbox/project/sw-osbox-core-web/src/




  echo "staticnetwork,10,Network configuration completed.">/etc/osbox/setup.state
else
   echo "finished,10,finished">/etc/osbox/setup.state
fi




#echo "finished,10,finished">/etc/osbox/setup.state


systemctl disable osbox-install
rm -f /etc/systemd/system/osbox-install.service

echo 0 > /sys/class/leds/nanopi:red:pwr/brightness
