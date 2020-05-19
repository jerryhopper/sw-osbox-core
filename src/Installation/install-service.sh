#!/bin/bash


set -e

if [ -f "/sys/class/leds/nanopi:red:pwr" ]; then
    # set the led to blinking
    echo "heartbeat" > /sys/class/leds/nanopi:red:pwr/trigger
fi

sudo echo "running,10,Preparing files.">/etc/osbox/setup.state



# preset some configs
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_ftl.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_blocklists.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_setupvars.sh

sleep 1

# installing required software
sudo echo "running,10,Installing requirements">/etc/osbox/setup.state
apt-get -y install php-common php-sqlite3 php-xml php-intl php-zip php-mbstring php-gd php-apcu php-cgi composer dialog dhcpcd5 dnsutils lsof nmap netcat idn2 dns-root-data composer

# download and run the pihole installer
sudo echo "running,10,Installing services (this may take a while)">/etc/osbox/setup.state
rm -f ./basic-install.sh
wget https://raw.githubusercontent.com/pi-hole/pi-hole/master/automated%20install/basic-install.sh
bash ./basic-install.sh --unattended


#sudo echo "running,10,Upgrading release">/etc/osbox/setup.state

# Set pihole repo to V5 beta
#echo "release/v5.0" | sudo tee /etc/pihole/ftlbranch
#echo "yes"|pihole checkout core release/v5.0
#echo "yes"|pihole checkout web release/v5.0


sudo echo "running,10,Preparing files.">/etc/osbox/setup.state

# set our default configs.
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_ftl.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_blocklists.sh
bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_setupvars.sh
sleep 1


#echo "dns-loop-detect">/etc/dnsmasq.d/99-ipbinding.conf
#echo "except-interface=lo">>/etc/dnsmasq.d/99-ipbinding.conf
#echo "listen-address=10.0.1.4">>/etc/dnsmasq.d/99-ipbinding.conf
#echo "bind-interfaces">>/etc/dnsmasq.d/99-ipbinding.conf



# get osbox-core-web
if [ -d "/usr/local/osbox/project/sw-osbox-core-web" ]; then
    rm -rf /usr/local/osbox/project/sw-osbox-core-web
fi

# remove osbox
if [ -f "/var/www/html/osbox" ]; then
    rm -rf /var/www/html/osbox
fi
sudo echo "running,10,Installing blackbox web.">/etc/osbox/setup.state

# get gitrepository
git clone https://github.com/jerryhopper/sw-osbox-core-web.git /usr/local/osbox/project/sw-osbox-core-web



PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar --working-dir=/usr/local/osbox/project/sw-osbox-core-web install


# set permissions
chmod -R +r /usr/local/osbox/project/sw-osbox-core-web

# symlink
ln -s /usr/local/osbox/project/sw-osbox-core-web /var/www/html/osbox

# create index file
echo "<?php include(\"./osbox/index.php\"); \$app->run(); " > /var/www/html/index.php








IP="$(osbox network info|awk -F ',' '{print $1}')"
NETTYPE="$(osbox network info|awk -F ',' '{print $2}')"

echo "NETTYPE='$NETTYPE'"

if [ "$NETTYPE" == "STATIC" ];then

  echo "$IP nonexistent.surfwijzer.nl" > /etc/pihole/custom.list
  echo "$IP blackbox.surfwijzer.nl" >> /etc/pihole/custom.list

  echo "$IP osbox" > /etc/pihole/local.list
  echo "$IP pi.hole" >> /etc/pihole/local.list





  echo "staticnetwork,10,Network configuration completed.">/etc/osbox/setup.state
else
   echo "finished,10,finished">/etc/osbox/setup.state
fi




#echo "finished,10,finished">/etc/osbox/setup.state


systemctl disable osbox-install
rm -f /etc/systemd/system/osbox-install.service

if [ -f "/sys/class/leds/nanopi:red:pwr" ]; then
    echo 0 > /sys/class/leds/nanopi:red:pwr/brightness
fi


echo "IDP_CLIENTID=82252ce6-ad4a-4a7f-8ff3-f7074f1a58dc">/etc/osbox/osbox.ini
echo "IDP_AUTHORIZE_URL=https://idp.surfwijzer.nl/oauth2/authorize">>/etc/osbox/osbox.ini
echo "IDP_ISSUER=idp.surfwijzer.nl">>/etc/osbox/osbox.ini
echo "IDP_REDIRECT_URL=https://setup.surfwijzer.nl/blackbox/login">>/etc/osbox/osbox.ini


