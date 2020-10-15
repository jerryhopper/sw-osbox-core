#!/bin/bash

source /usr/local/osbox/project/sw-osbox-core/src/BashScripts/fn/networktools.sh
source /usr/local/osbox/project/sw-osbox-core/src/BashScripts/fn/is_command.sh


set -e

#echo $(netmask 24)

#IPV4_ADDRESS="10.0.1.4/24"
#string="10.0.1.4/24"

# set_static_ip 10.0.1.4/24 10.0.1.1

##############################################
IFS='/' read -r -a array <<< "$1"
# ip/size
IP="${array[0]}"
SIZE="${array[1]}"

#echo $IP
#echo $SIZE



if  ! valid_ip "$IP" ; then
  echo "invalid ip ($IP)"
  exit 1
fi

# calc subnet from size
SUBNET="$(netmask $SIZE)"

if  ! valid_ip "$SUBNET" ; then
  echo "invalid subnet ($SUBNET)"
  exit 1
fi

#echo $SUBNET

if  ! valid_ip "$2" ; then
  echo "invalid gateway ip ($2)"
  exit 1
fi
GATEWAY="$2"





echo "IP $IP SUB $SUBNET GW $GATEWAY"


bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_pihole_setupvars.sh "$1"



echo  "# Location: /etc/network/interfaces ">/etc/network/interfaces
echo  "# Please modify network settings via: dietpi-config">>/etc/network/interfaces
echo  "# Or create your own drop-ins in: /etc/network/interfaces.d/">>/etc/network/interfaces
echo  " ">>/etc/network/interfaces
echo  "# Drop-in configs">>/etc/network/interfaces
echo  "source interfaces.d/*">>/etc/network/interfaces
echo  " ">>/etc/network/interfaces
echo  "# Loopback">>/etc/network/interfaces
echo  "auto lo">>/etc/network/interfaces
echo  "iface lo inet loopback">>/etc/network/interfaces
echo  " ">>/etc/network/interfaces
echo  "# Ethernet">>/etc/network/interfaces
echo  "allow-hotplug eth0">>/etc/network/interfaces
echo  "iface eth0 inet static">>/etc/network/interfaces
echo  "address $IP">>/etc/network/interfaces
echo  "netmask $SUBNET">>/etc/network/interfaces
echo  "gateway $GATEWAY">>/etc/network/interfaces
echo  "#dns-nameservers 8.8.8.8 8.8.4.4">>/etc/network/interfaces
echo  " ">>/etc/network/interfaces
echo  "# WiFi">>/etc/network/interfaces
echo  "#allow-hotplug wlan0">>/etc/network/interfaces
echo  "iface wlan0 inet dhcp">>/etc/network/interfaces
echo  "address 192.168.0.100">>/etc/network/interfaces
echo  "netmask 255.255.255.0">>/etc/network/interfaces
echo  "gateway 192.168.0.1">>/etc/network/interfaces
echo  "wireless-power off">>/etc/network/interfaces
echo  "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf">>/etc/network/interfaces
echo  "#dns-nameservers 8.8.8.8 8.8.4.4">>/etc/network/interfaces





bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_dhcpcd.sh $1 $GATEWAY

echo "$IP nonexistent.surfwijzer.nl" > /etc/pihole/custom.list
echo "$IP blackbox.surfwijzer.nl" >> /etc/pihole/custom.list

echo "$IP osbox" > /etc/pihole/local.list
echo "$IP pi.hole" >> /etc/pihole/local.list
