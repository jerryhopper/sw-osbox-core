#!/bin/bash

source /usr/local/osbox/project/sw-osbox-core/src/BashScripts/fn/networktools.sh
source /usr/local/osbox/project/sw-osbox-core/src/BashScripts/fn/is_command.sh


if [ "$1" == "" ];then
  find_IPv4_information

else
  IPV4_ADDRESS=$1
fi


mkdir -p /etc/pihole
echo "PIHOLE_INTERFACE=eth0" >/etc/pihole/setupVars.conf
#echo "IPV4_ADDRESS=10.0.1.207/24" >>/etc/pihole/setupVars.conf
echo "IPV4_ADDRESS=$IPV4_ADDRESS" >>/etc/pihole/setupVars.conf
echo "IPV6_ADDRESS=" >>/etc/pihole/setupVars.conf
echo "PIHOLE_DNS_1=8.8.8.8" >>/etc/pihole/setupVars.conf
echo "PIHOLE_DNS_2=8.8.4.4" >>/etc/pihole/setupVars.conf
echo "QUERY_LOGGING=false" >>/etc/pihole/setupVars.conf
echo "INSTALL_WEB_SERVER=true" >>/etc/pihole/setupVars.conf
echo "INSTALL_WEB_INTERFACE=true" >>/etc/pihole/setupVars.conf
echo "LIGHTTPD_ENABLED=true" >>/etc/pihole/setupVars.conf
echo "BLOCKING_ENABLED=true" >>/etc/pihole/setupVars.conf
echo "DNSMASQ_LISTENING=single" >>/etc/pihole/setupVars.conf
echo "DNS_FQDN_REQUIRED=true" >>/etc/pihole/setupVars.conf
echo "DNS_BOGUS_PRIV=true" >>/etc/pihole/setupVars.conf
#echo "DNSSEC=true" >>/etc/pihole/setupVars.conf
echo "TEMPERATUREUNIT=C" >>/etc/pihole/setupVars.conf
#echo "CONDITIONAL_FORWARDING=true" >>/etc/pihole/setupVars.conf
#echo "CONDITIONAL_FORWARDING_IP=10.0.1.1" >>/etc/pihole/setupVars.conf
#echo "CONDITIONAL_FORWARDING_DOMAIN=localdomain" >>/etc/pihole/setupVars.conf
#echo "CONDITIONAL_FORWARDING_REVERSE=1.0.10.in-addr.arpa" >>/etc/pihole/setupVars.conf
echo "WEBPASSWORD=84ea6bece4df810e8a3d53ba0e6c5ff9cdc5c25ddd2d8b6ad5c5e009015c3e54" >>/etc/pihole/setupVars.conf

