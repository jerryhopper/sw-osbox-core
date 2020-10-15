#!/bin/bash


network="$(bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/info.sh|awk -F"," '{print $3}')"
nmap -v -sn $network -oG -|grep Host|awk '{if(NR>1)print}'
