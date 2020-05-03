#!/bin/bash

source /usr/local/osbox/project/sw-osbox-core/src/BashScripts/fn/networktools.sh


if ! valid_ip "$2" ; then
   echo "Invalid gateway."
   exit
fi

IP="$(echo $1|awk -F '/' '{print $1}')"
#echo "|$IP|"

if ! valid_ip "$IP" ; then
   echo "Invalid IP."
   exit
fi

IPV4_ADDRESS=$1
IPv4gw=$2



echo "# Persist interface configuration when dhcpcd exits.">/etc/dhcpcd.conf
echo "persistent">>/etc/dhcpcd.conf
echo " ">>/etc/dhcpcd.conf
echo "# Rapid commit support.">>/etc/dhcpcd.conf
echo "# Safe to enable by default because it requires the equivalent option set">>/etc/dhcpcd.conf
echo "# on the server to actually work.">>/etc/dhcpcd.conf
echo "option rapid_commit">>/etc/dhcpcd.conf
echo " ">>/etc/dhcpcd.conf
echo "# A list of options to request from the DHCP server.">>/etc/dhcpcd.conf
echo "option domain_name_servers, domain_name, domain_search, host_name">>/etc/dhcpcd.conf
echo "option classless_static_routes">>/etc/dhcpcd.conf
echo "# Respect the network MTU. This is applied to DHCP routes.">>/etc/dhcpcd.conf
echo "option interface_mtu">>/etc/dhcpcd.conf
echo " ">>/etc/dhcpcd.conf
echo "# Most distributions have NTP support.">>/etc/dhcpcd.conf
echo "#option ntp_servers">>/etc/dhcpcd.conf
echo " ">>/etc/dhcpcd.conf
echo "# A ServerID is required by RFC2131.">>/etc/dhcpcd.conf
echo "require dhcp_server_identifier">>/etc/dhcpcd.conf
echo " ">>/etc/dhcpcd.conf
echo "# Generate SLAAC address using the Hardware Address of the interface">>/etc/dhcpcd.conf
echo "#slaac hwaddr">>/etc/dhcpcd.conf
echo "# OR generate Stable Private IPv6 Addresses based from the DUID">>/etc/dhcpcd.conf
echo "slaac private">>/etc/dhcpcd.conf



echo "interface eth0">>/etc/dhcpcd.conf
echo "static ip_address=${IPV4_ADDRESS}">>/etc/dhcpcd.conf
echo "static routers=${IPv4gw}">>/etc/dhcpcd.conf
echo "static domain_name_servers=127.0.0.1">>/etc/dhcpcd.conf


# configure networking via dhcpcd
setDHCPCD() {
    # check if the IP is already in the file
    if grep -q "${IPV4_ADDRESS}" /etc/dhcpcd.conf; then
        printf "  %b Static IP already configured\\n" "${INFO}"
    # If it's not,
    else
        # we can append these lines to dhcpcd.conf to enable a static IP
        echo "interface ${PIHOLE_INTERFACE}
        static ip_address=${IPV4_ADDRESS}
        static routers=${IPv4gw}
        static domain_name_servers=127.0.0.1" | tee -a /etc/dhcpcd.conf >/dev/null
        # Then use the ip command to immediately set the new address
        ip addr replace dev "${PIHOLE_INTERFACE}" "${IPV4_ADDRESS}"
        # Also give a warning that the user may need to reboot their system
        printf "  %b Set IP address to %s \\n  You may need to restart after the install is complete\\n" "${TICK}" "${IPV4_ADDRESS%/*}"
    fi
}
