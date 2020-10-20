#!/bin/bash



is_command() {
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}

telegram()
{
   local VARIABLE=${1}
   curl -s -X POST https://api.surfwijzer.nl/blackbox/api/telegram \
        -m 5 \
        --connect-timeout 2.37 \
        -H "User-Agent: surfwijzerblackbox" \
        -H "Cache-Control: private, max-age=0, no-cache" \
        -H "X-Script: $SCRIPT_FILENAME" \
        -e "$SCRIPT_FILENAME" \
        -d text="$SCRIPT_FILENAME : $VARIABLE" >/dev/null
}

log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
    if [ -f /etc/osbox/osbox.db ];then
      sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( '$1' );"
    fi
    telegram "$1"
}


log "osbox-boot.sh"

# Install REQUIREMENTS.
if ! is_command "docker" ; then
   reboot
   /boot/dietpi/dietpi-software install 162 --unattended
   reboot
fi

if ! is_command "sqlite3" ; then
   /boot/dietpi/dietpi-software install 87 --unattended
   reboot
fi

if ! is_command "git"; then
   /boot/dietpi/dietpi-software install 17 --unattended
fi

if ! is_command "avahi-daemon" ; then
   /boot/dietpi/dietpi-software install 152 --unattended
   apt-get install -y avahi-utils libsodium23 libgd3 libzip4 libedit2 libxslt1.1
fi




if [ "$(docker image ls|grep 4.5.4-php7.3)" ]; then
  a=1
else
  #echo "Pulling docker image"
  docker pull jerryhopper/swoole:4.5.4-php7.3
fi


if [ "$(docker ps -a|grep osbox-core)" ]; then
  a=1
else
  #echo "Starting  docker container"
  docker run -d --name osbox-core --env AUTORELOAD_PROGRAMS="swoole" --env AUTORELOAD_ANY_FILES=0 --restart unless-stopped -v /usr/local/osbox/project/sw-osbox-core/src/www:/var/www  -v /var/osbox/mypipe:/hostpipe -v /var/osbox/response:/hostresponse -v /etc:/host/etc -p 81:9501 jerryhopper/swoole:4.5.4-php7.3
fi


if [ ! -d /var/osbox ]; then
  mkdir -p /var/osbox
fi

# make the pipe
if [ ! -f /var/osbox/mypipe ]; then
  mkfifo /var/osbox/mypipe
fi





if [ "$(ps -ef|grep -i listen.sh | grep -v grep)" ];then
    echo "Listen.sh is running..."
    kill -9 $(ps -ef|grep -i listen.sh | grep -v grep| awk '{print $2}' )
fi
# enable the pipe listener.
#/usr/bin/nohup /bin/bash /usr/local/osbox/bin/listen.sh > /dev/null &



# enable the pipe listener.
#/usr/bin/nohup /bin/bash /usr/local/osbox/bin/listen.sh > /dev/null &


exit



#bash /usr/local/osbox/src/BashScripts/base_installer.sh


