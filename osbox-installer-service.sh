#!/bin/bash

# installation log
is_running() {
    ps -o comm= -C "$1" 2>/dev/null | grep -x "$1" >/dev/null 2>&1
}


is_command() {
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}

log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
}

install_docker(){
  /boot/dietpi/dietpi-software install 162 --unattended
  if ! "$?" = "0"; then
    reboot
  fi
}

log "osbox-installer-service"



# Loop until install-stage is finished.
while true; do

  # check if dietpi is installed completely
  if [ -f /boot/dietpi/.installed ] ; then

    # Check if docker is available.
    if ! is_command docker ; then
      log "Docker is not available"
      ## checking if "apt" is running
      if is_running apt; then
          log "apt is running"
          exit
      else
          log "apt is not running"
          install_docker

          reboot
          exit
      fi

    else
      ## docker exists
      log "Docker exists"
      # check if container is available
      exit
    fi
  else
    log "sleep 60"
    sleep 60
  fi
done



