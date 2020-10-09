#!/bin/bash


SCRIPT_FILENAME=""
# installation log
is_running() {
    ps -o comm= -C "$1" 2>/dev/null | grep -x "$1" >/dev/null 2>&1
}


is_command() {
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


telegram()
{
   local VARIABLE=${1}
   curl -s -X POST https://api.surfwijzer.nl/blackbox/api/telegram \
        -H "User-Agent: surfwijzerblackbox" \
        -H "Cache-Control: private, max-age=0, no-cache" \
        -H "X-Script: $SCRIPT_FILENAME" \
        -e "$SCRIPT_FILENAME" \
        -d text="$SCRIPT_FILENAME : $VARIABLE" >/dev/null
}


log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
    telegram "$1"
}

test_composer(){
  if [ ! -d /usr/local/osbox/project/sw-osbox-core/src/www/vendor ]; then
    log "Missing composer dependencies"
    docker run --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install
    if [  $? = "0" ]; then
      log "Composer dependencies installed ok."
    else
      log "ERROR! [$?] docker run composer install returned error. "
      exit 1
    fi
  else
    log "Composer dependencies are ok"
  fi
}

start_osboxcore(){
  # check if container is available
  # -env AUTORELOAD_PROGRAMS="swoole" -env AUTORELOAD_ANY_FILES=0
  log "start_osboxcore()"
  test_composer
  if [ "$(docker ps -a|grep osbox-core)" ]; then
      log "docker container osbox-core is running!"
      systemctl stop osbox-installer
      log "Disabling installer service"
      systemctl disable osbox-installer
  else
      log "Running composer"
      test_composer
      #docker run --rm --interactive --tty --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install

      log "Starting  docker container"
      docker run -d --name osbox-core --env AUTORELOAD_PROGRAMS="swoole" --env AUTORELOAD_ANY_FILES=0 --restart unless-stopped -v /usr/local/osbox/project/sw-osbox-core/src/www:/var/www  -v /var/osbox:/host/osbox -v /etc:/host/etc -p 81:9501 jerryhopper/swoole:4.5.4-php7.3
      if [  $? = "0" ]; then
        log "Disabling installer service"

        /boot/dietpi/func/change_hostname osbox
        cp /usr/local/osbox/lib/avahi/osbox.service /etc/avahi/services
        systemctl restart avahi-daemon.service
        systemctl stop osbox-installer
        systemctl disable osbox-installer
        log "Reboot!"
        #reboot
      else
        log "ERROR!  docker run  swoole returned error. "
        exit 1
      fi



      #systemctl enable osbox-installer



  fi

}

install_docker(){
  log "Installing docker"
  /boot/dietpi/dietpi-software install 162 --unattended
  if ! $? = 0; then
    log "installation of docker failed!  rebooting!"
    sleep 15
    exit
    #reboot
  fi
  log "Pulling image"
  docker pull jerryhopper/swoole:4.5.4-php7.3
  if ! $? = 0; then
    log "Failed: docker pull jerryhopper/swoole:4.5.4-php7.3"
    sleep 15
    exit
    #reboot
  fi
}




log "Starting osbox-installer-service"



# Loop until install-stage is finished.
while true; do
  sleep 20

  # check if dietpi is installed completely
  if [ -f /boot/dietpi/.installed ] ; then

    INSTALLSTAGE="$(</boot/dietpi/.install_stage)"
    if [  $INSTALLSTAGE = "2" ]; then
      # Check if docker is available.
      if ! is_command docker ; then
        log "Docker is not available"

        # checking if "apt" is running
        if is_running apt; then
            log "apt is running"
            sleep 60
            exit
        else
            install_docker
            exit
        fi

      else
        log "Docker exists, exiting osbox-installer"
        ## docker exists
        #log "Docker exists"
        systemctl stop osbox-installer
        systemctl disable osbox-installer
        #start_osboxcore
        exit
      fi
    else
      log "install-state is not 2. is installer busy?"
      sleep 120
    fi


  else
    # /boot/dietpi/.installed doesnt exist.
    log "sleep 60"
    sleep 120
  fi
done



