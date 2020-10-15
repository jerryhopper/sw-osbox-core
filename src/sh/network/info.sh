#!/bin/bash

source /usr/local/osbox/project/sw-osbox-core/src/sh/network/fn_networktools.sh


find_IPv4_information

if [ ! "$(ip addr show eth0|grep "eth0"|grep dynamic)" ]; then
  ADDRESSING="STATIC";
else
  ADDRESSING="DHCP";
fi


echo "$IPv4bare,$ADDRESSING,$IPV4_ADDRESS,$IPv4gw"


