#!/bin/bash

source /usr/local/osbox/lib/bashfunc/is_root
source /usr/local/osbox/lib/bashfunc/is_command







IPv4bare=""
IPv4gw=""
IPV4_ADDRESS=""

# Check an IP address to see if it is a valid one
valid_ip() {
    # Local, named variables
    local ip=${1}
    local stat=1

    # If the IP matches the format xxx.xxx.xxx.xxx,
    if [[ "${ip}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Save the old Internal Field Separator in a variable
        OIFS=$IFS
        # and set the new one to a dot (period)
        IFS='.'
        # Put the IP into an array
        ip=(${ip})
        # Restore the IFS to what it was
        IFS=${OIFS}
        ## Evaluate each octet by checking if it's less than or equal to 255 (the max for each octet)
        [[ "${ip[0]}" -le 255 && "${ip[1]}" -le 255 \
        && "${ip[2]}" -le 255 && "${ip[3]}" -le 255 ]]
        # Save the exit code
        stat=$?
    fi
    # Return the exit code
    return ${stat}
}



find_IPv4_information() {
    # Detects IPv4 address used for communication to WAN addresses.
    # Accepts no arguments, returns no values.

    # Named, local variables
    local route
    #local IPv4bare

    # Find IP used to route to outside world by checking the the route to Google's public DNS server
    route=$(ip route get 8.8.8.8)

    # Get just the interface IPv4 address
    # shellcheck disable=SC2059,SC2086
    # disabled as we intentionally want to split on whitespace and have printf populate
    # the variable with just the first field.
    printf -v IPv4bare "$(printf ${route#*src })"
    # Get the default gateway IPv4 address (the way to reach the Internet)
    # shellcheck disable=SC2059,SC2086
    printf -v IPv4gw "$(printf ${route#*via })"

    if ! valid_ip "${IPv4bare}" ; then
        IPv4bare="127.0.0.1"
    fi

    # Append the CIDR notation to the IP address, if valid_ip fails this should return 127.0.0.1/8
    IPV4_ADDRESS=$(ip -oneline -family inet address show | grep "${IPv4bare}/" |  awk '{print $4}' | awk 'END {print}')
}

find_IPv4_information


if ! is_command avahi-browse ;then
   apt-get -f install avahi-utils
fi

#if ! is_command nmap ;then
#   #apt-get -f install nmap
#fi

if ! is_command git ;then
   apt-get -f install git
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



#  avahi-browse -rtp _osboxdns._tcp|grep =;
echo " $IP $PORT $HOST"
exit;

# apt get avahi-utils

# fuser 80/tcp
# fuser 443/tcp
PID=$(fuser 9501/tcp 2>/dev/null)
PROG=$( ps -p $PID|grep $PID|awk '{ print $4 }' )
BIN=$( ps -f -p $PID|grep $PID|awk '{ print $8 }' )


if is_command lighttpd ; then
   echo "lighthttpd is available"
fi
echo $PROG
echo $BIN

#exit

# avahi-browse -rtp _osboxmaster._tcp|grep "=;eth0;IPv4"
# avahi-browse -rtp _osbox._tcp|grep "=;eth0;IPv4"


#  avahi-browse -rtp _osboxdns._tcp|grep =;

exit;

systemctl stop osbox
systemctl disable osbox

rm /etc/systemd/system/osbox.service
#rm /usr/lib/systemd/system/osbox

systemctl stop osbox-scheduler
systemctl disable osbox-scheduler

rm /etc/systemd/system/osbox-scheduler.service
#rm /usr/lib/systemd/system/osbox-scheduler




systemctl daemon-reload
systemctl reset-failed






# check user.

if id "osbox" >/dev/null 2>&1; then
   echo "user exists"
else
   echo "user does not exist"
   sudo adduser --disabled-password --shell /bin/bash --gecos "User" osbox
fi

if [ ! -f /etc/systemd/system/osbox.service ]; then
    cp ./lib/systemd/osbox.service  /etc/systemd/system
    systemctl enable osbox
else
    echo "osbox.service exists"
fi

if [ ! -f /etc/systemd/system/osbox-scheduler.service ]; then
    cp ./lib/systemd/osbox-scheduler.service  /etc/systemd/system
    systemctl enable osbox-scheduler
else
    echo "osbox-scheduler.service exists"

fi

if [ ! -d /etc/osbox ]; then
    mkdir /etc/osbox
    chown -R osbox:osbox /etc/osbox
else
    echo "/etc/osbox exists"
fi

#if [ ./project/osbox-core ]; then
#     git clone https://githubbblablablabla  ./project
#else
#     echo "./project/osbox-core exists"
#fi



cd ./project

for d in */ ; do
    cd "$d"
    echo  "Update $d"
    git fetch --all
    git reset --hard origin/master
    #git pull origin master
    cd ..
done

cd ..

#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar --working-dir=/usr/local/osbox/project/sw-osbox-core update



# avahi = 152 in dietpi software.
if [ -d /etc/avahi/services ]; then
   echo "copy avahi services"
   cp ./lib/avahi/* /etc/avahi/services
   service avahi-daemon restart
fi


# ssl
if [ ! -d /etc/osbox/ssl/blackbox.surfwijzer.nl ]; then
   echo "no ssl certs!"
   # wget ssl certs.
fi

echo "Restarting services"
systemctl restart osbox
systemctl restart osbox-scheduler


#PHP_INI_SCAN_DIR=./bin/conf.d
#./bin/osboxd -c ./bin/osboxd.ini -f ./project/osbox-core/src/osbox-update.php


