#!/bin/bash

# osbox discover master
IFS=
if [ "$1" == "master" ];then
  MASTER=$(avahi-browse -rtp _osboxmaster._tcp|grep "=;eth0;IPv4")
  echo $MASTER
  exit
fi
# osbox discover all
if [ "$1" == "all" ];then
  BOXES=$(avahi-browse -rtp _osbox._tcp|grep "=;eth0;IPv4")
  echo $BOXES

  exit
fi

echo "Usage 'osbox discover X' :"
echo "  master"
echo "  all"


