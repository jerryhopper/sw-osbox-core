#!/bin/bash



is_command() {
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}




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


# enable the pipe listener.
/usr/bin/nohup /bin/bash /usr/local/osbox/bin/listen.sh > /dev/null &


#bash /usr/local/osbox/src/BashScripts/base_installer.sh


