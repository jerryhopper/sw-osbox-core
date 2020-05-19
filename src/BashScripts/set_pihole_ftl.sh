#!/bin/bash

if [ ! -d "/etc/pihole" ];then
  mkdir "/etc/pihole"
fi
echo "PRIVACYLEVEL=0" >/etc/pihole/pihole-FTL.conf
echo "BLOCKINGMODE=NULL" >>/etc/pihole/pihole-FTL.conf
