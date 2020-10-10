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
    run_composer
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

disable_installer(){
  systemctl stop osbox-installer
  log "Disabling installer service"
  systemctl disable osbox-installer
}














docker_pull_composer(){
    log "Pulling composer image"
    docker pull composer
    if $? = "0"; then
      echo "ok"
    else
      log "Failed: docker pull composer"
      exit 1
    fi
}
docker_image_composer_exists(){
    if [ "$(docker image ls|grep composer)" ]; then
        log "docker 'composer' image exists."
        #result
    else
        log "docker 'composer' image does not exist."
        #noresult
    fi
}
docker_container_composer_exists(){
    if [ "$(docker container ls|grep composer)" ]; then
        log "docker 'composer' container exists."
        #result
    else
        log "docker 'composer' container does not exist."
        #noresult
    fi
}

docker_run_composer(){
  docker run --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install
  if $? = "0"; then
    echo "ok"
  else
    log "Failed: docker run composer"
    exit 1
  fi
}










docker_container_exists(){
    $(docker container ls|grep $1)
}

docker_image_exists(){
    $(docker image ls|grep $1)
}

docker_pull(){
  log "docker pull $1"
  $(docker pull $1)
}


docker_image_swoole_exists(){
    if [ "$(docker image ls|grep jerryhopper/swoole)" ]; then
      log "docker 'jerryhopper/swoole' image exists."
      #result
    else
      log "docker 'jerryhopper/swoole' image doesnt exist."
      #noresult
    fi
}
docker_pull_swoole(){
  log "Pulling swoole image"
  docker pull jerryhopper/swoole:4.5.4-php7.3
  if $? = "0"; then
    echo "ok"
  else
    log "Failed: docker pull jerryhopper/swoole:4.5.4-php7.3"
    exit 1
  fi
}
docker_run_swoole(){
  log "Starting  docker container"
  docker run -d --name osbox-core --env AUTORELOAD_PROGRAMS="swoole" --env AUTORELOAD_ANY_FILES=0 --restart unless-stopped -v /usr/local/osbox/project/sw-osbox-core/src/www:/var/www  -v /var/osbox:/host/osbox -v /etc:/host/etc -p 81:9501 jerryhopper/swoole:4.5.4-php7.3
  if $? = "0"; then
    echo "ok"
  else
    log "Failed: docker run swoole"
    exit 1
  fi
}






install_docker(){
  log "Installing docker"
  /boot/dietpi/dietpi-software install 162 --unattended
  if $? = "0"; then
    echo "ok"
  else
    log "installation of docker failed!  rebooting!"
    exit 1
  fi

}


start_osboxcore(){
  # check if container is available
  # -env AUTORELOAD_PROGRAMS="swoole" -env AUTORELOAD_ANY_FILES=0
  log "start_osboxcore()"
  test_composer
  if [ "$(docker ps -a|grep osbox-core)" ]; then
      log "docker container osbox-core is running!"
      disable_installer
  else
      log "Running composer"
      test_composer
      #docker run --rm --interactive --tty --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install

      run_swoole

      if [  $? = "0" ]; then
        log "Disabling installer service"

        /boot/dietpi/func/change_hostname osbox
        cp /usr/local/osbox/lib/avahi/osbox.service /etc/avahi/services
        systemctl restart avahi-daemon.service

        disable_installer
        log "Reboot!"
        #reboot
      else
        log "ERROR!  docker run  swoole returned error. "
        exit 1
      fi



      #systemctl enable osbox-installer



  fi

}
























log "Starting osbox-installer-service"

# check if dietpi is installed completely
if [ -f /boot/dietpi/.installed ] ; then

  INSTALLSTAGE="$(</boot/dietpi/.install_stage)"
  if [  $INSTALLSTAGE = "2" ]; then
      # Check if docker is available.
      if ! is_command docker ; then
          # Docker is not available.
          # checking if "apt" is running
          if is_running apt; then
                exit
          else
                install_docker
                exit
          fi
      else
          log "Docker exists, exiting osbox-installer"
          if docker_image_exists "composer"; then
              log "Composer image is available."
          else
              log "Composer image is not available."
              docker_pull "composer"

          fi


          if [ ! -d /usr/local/osbox/project/sw-osbox-core/src/www/vendor ]; then
              docker_run_composer
          fi

          if docker_image_exists "jerryhopper/swoole"; then
              log "Swoole image is available."
          else
              log "Swoole image is not available."
              docker_pull "jerryhopper/swoole:4.5.4-php7.3"
          fi

          if docker_container_exists "osbox-core"; then
              log "osbox-core container is available."
          else
              log "osbox-core container is not available."
          fi


          ## docker exists
          #log "Docker exists"
          disable_installer
          #start_osboxcore
          exit
      fi
  else
        log "install-state is not 2. is installer busy?"
        sleep 10
  fi
fi
