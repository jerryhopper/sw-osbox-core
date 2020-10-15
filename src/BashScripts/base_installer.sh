#!/bin/bash


OSBOX_BIN_USR="osbox"

# installation log
log(){
    echo "$(date) : $1">>/var/log/osbox-install.log
    echo "$(date) : $1"
}


# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


createUser(){
    # adduser
    log "Checking for $OSBOX_BIN_USR user."
    if id -u osbox >/dev/null 2>&1; then
        log "Skipping, user '${OSBOX_BIN_USR}' already exists."
    else
        useradd -m osbox
        log "Adding ${OSBOX_BIN_USR} user."
    fi


    # add to sudoers
    if [ -f /etc/sudoers.d/${OSBOX_BIN_USR} ]; then
       rm -f /etc/sudoers.d/${OSBOX_BIN_USR}
    fi
    echo "${OSBOX_BIN_USR} ALL=NOPASSWD: ${OSBOX_BIN_INSTALLDIR}osbox">/etc/sudoers.d/${OSBOX_BIN_USR}
}



configureAvahi(){

  # check if avahi-daemon command exists.
  if ! is_command avahi-daemon ; then
      echo "Error. avahi-daemon is not available."
      echo "Trying to install avahi-daemon."
      log "Trying to install avahi-daemon."
      /boot/dietpi/dietpi-software install 152 --unattended
      #exit
  else
      log "avahi-daemon is available"
  fi


  # copy avahi configuration
  echo "Configuring avahi."
  log "Configuring avahi."
  if [ -f /etc/avahi/services/osbox.service ]; then
    rm -f /etc/avahi/services/osbox.service
  fi
  if [ -f /etc/avahi/services/osbox.master.service ]; then
    rm -f /etc/avahi/services/osbox.master.service
  fi
  cp /usr/local/osbox/lib/avahi/osbox.service /etc/avahi/services/osbox.service
  systemctl restart avahi-daemon
}

sethostname() {
    # Set the hostname
    echo "127.0.0.1 localhost">/etc/hosts
    echo "127.0.1.1 osbox">>/etc/hosts
    echo "::1       localhost ip6-localhost ip6-loopback">>/etc/hosts
    echo "ff02::1   ip6-allnodes">>/etc/hosts
    echo "ff02::2   ip6-allrouters">>/etc/hosts
    echo "osbox">/etc/hostname
    hostnamectl set-hostname osbox
}



#ln -s  ${OSBOX_BIN_INSTALLDIR}osbox-boot /var/lib/dietpi/postboot.d/osbox-boot
#chmod +x /var/lib/dietpi/postboot.d/osbox-boot



sethostname
# setup and configure avahi
configureAvahi


# Installer!
bash /usr/local/osbox/osbox update


# check if avahi-daemon command exists.
if ! is_command avahi-daemon ; then
    echo "Error. avahi-daemon is not available."
    echo "Trying to install avahi-daemon."
    log "Trying to install avahi-daemon."
    /boot/dietpi/dietpi-software install 152 --unattended
    apt-get install -y avahi-utils libsodium23 libgd3 libzip4 libedit2 libxslt1.1
    #exit
else
    log "avahi-daemon is available"
fi


if ! is_command avahi-browse ; then
   log "Trying to install avahi-utils."
   apt-get install -y avahi-utils libsodium23 libgd3 libzip4 libedit2 libxslt1.1
else
   log "avahi-utils are available."
fi


if ! is_command nmap ; then
   log "Trying to install avahi-utils."
   apt-get install -y nmap
else
   log "avahi-utils are available."
fi

if ! is_command sqlite3 ; then
   log "Trying to install sqlite ."
   #//apt-get install -y nmap
   /boot/dietpi/dietpi-software install 87 --unattended

else
   log "sqlite is available."
fi


#ln -s /var/lib/dietpi/postboot.d/osbox-boot /usr/local/osbox/osbox-boot


if [  -f /var/lib/dietpi/postboot.d/requirements.sh  ]; then
    rm -f /var/lib/dietpi/postboot.d/requirements.sh
fi
#
if [ ! -f /var/lib/dietpi/postboot.d/requirements.sh  ]; then
  log "set boot-time requirements"

  echo "bash /usr/local/osbox/src/BashScripts/base_installer.sh"
fi


# check if sqlite3 db exists.
#
#  /host/etc/osbox/master.db
#  /host/etc/osbox/osbox.db
if [ ! -f /etc/osbox/osbox.db ];then
  touch /etc/osbox/osbox.db
  sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
  sqlite3 -batch /etc/osbox/osbox.db "INSERT INTO table ( installog ) VALUES( 'osbox.db created' );"

fi





# check if avahi-daemon command exists.
if ! is_command docker ; then
    log  "Error. docker is not available,rebooting"
    #reboot
    exit 0
else
    log "docker is available"
fi



chmod +x /usr/local/osbox/project/sw-osbox-core/src/www/server.php

createUser


# osbox-pipe-service!
if [ -d /var/osbox ]; then
  rm -rf /var/osbox
fi

if [ ! -d /var/osbox ]; then
  mkdir -p /var/osbox
fi

if [ ! -f /var/osbox/mypipe ]; then
  mkfifo /var/osbox/mypipe
fi

if [ -f /usr/local/osbox/lib/systemd/osbox-pipe.service ]; then
  rm -f /usr/local/osbox/lib/systemd/osbox-pipe.service
fi
#cp /usr/local/osbox/lib/systemd/osbox-pipe.service /etc/systemd/system
#systemctl daemon-reload



ln -s  ${OSBOX_BIN_INSTALLDIR}osbox-boot /var/lib/dietpi/postboot.d/osbox-boot
chmod +x /var/lib/dietpi/postboot.d/osbox-boot

if [ "$(ps -ef|grep -i listen.sh | grep -v grep)" ];then
    echo "Listen.sh is running..."
    kill -9 $(ps -ef|grep -i listen.sh | grep -v grep| awk '{print $2}' )
fi
# enable the pipe listener.
/usr/bin/nohup /bin/bash /usr/local/osbox/bin/listen.sh > /dev/null &


# -env AUTORELOAD_PROGRAMS="swoole" -env AUTORELOAD_ANY_FILES=0
if [ "$(docker ps -a|grep osbox-core)" ]; then
  a=1
else
  echo "Starting  docker container"
  docker run -d --name osbox-core --env AUTORELOAD_PROGRAMS="swoole" --env AUTORELOAD_ANY_FILES=0 --restart unless-stopped -v /usr/local/osbox/project/sw-osbox-core/src/www:/var/www  -v /var/osbox:/host/osbox -v /etc:/host/etc -p 81:9501 jerryhopper/swoole:4.5.4-php7.3
fi





