#!/bin/bash


source /usr/local/osbox/lib/bashfunc/is_root
source /usr/local/osbox/lib/bashfunc/is_command

exit






check_docker(){
  if ! is_command docker ; then
    addr
  fi

}


# Loop until install-stage is finished.
while true; do
  if "{cat /boot/dietpi/.install_stage }" = "2" ; then
    # Check if docker is available.
    if ! is_command docker ; then
      addr
    else
      ss
    fi
  else
    sleep 60
  fi
done








if "{cat /boot/dietpi/.install_stage }" = "2" ; then


  if "{cat /var/osbox/.install_stage}" = "2" ; then
     # stage is TWO
  fi

fi


exit

sleep 1


#check installation stage.

# /boot/dietpi/.install_stage  2

if ! is_command avahi-browse ;then
  echo "Somehow avahi-browse is missing. installing...."
  apt-get -y install avahi-utils
fi

if ! is_command nmap ;then
   apt-get -y install nmap
fi

if ! is_command git ;then
  echo "Somehow GIT is missing. installing...."
  apt-get -y install git
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


#sleep 5

# Check port 80
HTTPPID=$(fuser 80/tcp 2>/dev/null)
if [ $HTTPPID ]; then
  HTTPPROG=$( ps -p $HTTPPID |grep $HTTPPID |awk '{ print $4 }' )
  echo "HTTP  in use by $HTTPPROG"
else
  echo "Port 80 is not in use."
fi

# Check port 443
HTTPSPID=$(fuser 443/tcp 2>/dev/null)
if [ $HTTPSPID ]; then
  HTTPSPROG=$( ps -p $HTTPSPID |grep $HTTPSPID |awk '{ print $4 }' )
  echo "HTTPS in use by $HTTPSPROG"
else
  echo "Port 443 is not in use."
fi





#BIN=$( ps -f -p $PID|grep $PID|awk '{ print $8 }' )


#if is_command lighttpd ; then
#echo "lighthttpd is available"
#fi
echo $PROG
#echo $BIN



echo "*********************************"
cd /usr/local/osbox

PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/osbox-service.php

