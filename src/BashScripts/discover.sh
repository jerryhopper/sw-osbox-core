#!/bin/bash

#avahi-browse -a -p -t



#echo $1
IFS=
if [ "$1" == "master" ];then
  MASTER=$(avahi-browse -rtp _osboxmaster._tcp|grep "=;eth0;IPv4")
  echo $MASTER
  exit
fi
if [ "$1" == "all" ];then
  BOXES=$(avahi-browse -rtp _osbox._tcp|grep "=;eth0;IPv4")
  echo $BOXES

  exit
fi

echo "Usage 'osbox discover X' :"
echo "  master"
echo "  all"


#echo $MASTER;


#echo  $IPv4bare
exit;

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




