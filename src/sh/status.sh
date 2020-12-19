#!/bin/bash

#echo "status.sh"
if [ -f /etc/osbox/.dev ]; then
    RELEASE="latest"
else
    RELEASE="stable"
fi

if [ -f /etc/osbox/.board ]; then
    BOARD="$(</etc/osbox/.board)"
else
    BOARD="unknown"
fi


if [ -f /etc/osbox/.authorization ]; then
    DEVICE_STATE="registered"
    AUTHJSON="$(</etc/osbox/.authorization)"
    OWNER=",\"owner\":\"$(echo $AUTHJSON|jq -r .userId)\""
else
    DEVICE_STATE="unregistered"
    OWNER=""
fi

BIN_VERSION="$(</etc/osbox/.sw-osbox-bin.version)"
CORE_VERSION="$(</etc/osbox/.sw-osbox-core.version)"


SYSTEMNAME="$(uname -a)"


U="$(uptime)"
LOADAVG="$(echo "$U"|awk -F "," '{ print $4 "" $5 "" $6 }'|awk -F ": " '{print $2}')"




UPT="$(uptime | awk -F'( |,|:)+' '{d=h=m=0; if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"days,",h+0,"hours,",m+0,"minutes."}')"



JSON="{ \"uptime\":\"$UPT\"  , \"loadaverage\":\"$LOADAVG\",  \"release\":\"$RELEASE\",\"sw-osbox-bin\":\"$BIN_VERSION\",\"sw-osbox-core\":\"$CORE_VERSION\",\"device-state\":\"$DEVICE_STATE\",\"sys-info\":\"$SYSTEMNAME\",\"hardware\":\"$BOARD\"$OWNER}"

echo $JSON
exit

#rm /etc/osbox/osbox.db

if [ -f /etc/osbox/osbox.db ];then

    sqlite3 -batch /etc/osbox/osbox.db "select * from installog ;"

fi
