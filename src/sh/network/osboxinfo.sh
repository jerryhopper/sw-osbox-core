#!/bin/bash

set -e

#source /usr/local/osbox/project/sw-osbox-core/src/sh/network/fn_networktools.sh

if [ "$(ip addr|grep osbox)" == "" ];then
    echo "No osbox interface!"
    exit 1
fi


##find_IPv4_information

if [ ! "$(ip addr show osbox0|grep "osbox0"|grep dynamic)" ]; then
  ADDRESSING="STATIC";
else
  ADDRESSING="DHCP";
fi


IPv4gw="$(nmcli -g IP4.GATEWAY connection show "dummy-osbox0")"

IPV4_ADDRESS="$(nmcli -g IP4.ADDRESS connection show "dummy-osbox0")"


IPv4bare="$(nmcli -g IP4.ADDRESS connection show "dummy-osbox0"|awk -F "/" '{ print $1 }')"

printf "$IPv4bare,$ADDRESSING,$IPV4_ADDRESS,$IPv4gw"

exit

