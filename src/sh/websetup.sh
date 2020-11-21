#!/bin/bash


MASTER="$(osbox discover master)"

if [ "$MASTER" != "" ];then
  echo "MASTER AVAILABLE"
  # do something else...
  exit
fi


# No master, configure this device as master.
#echo "NO MASTER!"



source /usr/local/osbox/project/sw-osbox-core/src/sh/network/fn_networktools.sh

IPNET="$(getNetworkIpNet)"
IP="$(echo "${IPNET}"|awk -F '/' '{print $1}')"
createOsboxInterface "$IPNET"
sleep 1



#nmcli connection show|grep osbox

echo $IP
source /usr/local/osbox/project/sw-osbox-core/src/sh/docker/fn_dockertools.sh
getDockerApp "jerryhopper" "sw-osbox-pihole"
runDockerApp "jerryhopper" "sw-osbox-pihole"


#stopDockerApp "jerryhopper" "sw-osbox-pihole"
#removeDockerApp "jerryhopper" "sw-osbox-pihole"



exit








