#!/bin/bash

#avahi-browse -a -p -t





if ! is_command nmap ;then
   apt-get -y install nmap
fi


MASTER=$(avahi-browse -rtp _osboxmaster._tcp|grep "=;eth0;IPv4")
BOXES=$(avahi-browse -rtp _osbox._tcp|grep "=;eth0;IPv4")

#echo $MASTER;
echo $BOXES

#echo  $IPv4bare
#exit;

if [ "$MASTER" == "" ] ;then
    echo "NO MASTER ON NETWORK"

else
    echo "MASTER"
    IP=$(echo $MASTER|awk -F ';' '{ print $8 }')
    PORT=$(echo $MASTER|awk -F ';' '{ print $9 }')
    HOST=$(echo $MASTER|awk -F ';' '{ print $7 }')

    if [ $IPv4bare==$IP ]; then
      echo "i am master!"
    fi

fi


OSBOXMASTERHOST=$OSBOXMASTER|awk -F';' '{ print $7}'
OSBOXMASTERIP=$OSBOXMASTER|awk -F';' '{ print $8}'
OSBOXMASTERPORT=$OSBOXMASTER|awk -F';' '{ print $9}'


echo $(ip addr | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')




