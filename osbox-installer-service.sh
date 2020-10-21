#!/bin/bash




# Variables.
# Get the username.
if [ "$2" == "" ]; then
  OSBOX_BIN_USR="osbox"
else
  OSBOX_BIN_USR=$2
fi

#echo "$1 $2"
# Source the file if exist
if [ -f /etc/$OSBOX_BIN_USR/.setupconf ]; then
  source /etc/$OSBOX_BIN_USR/.setupconf
else
  # create the file for sourcing
  if [ "$1" == "dev" ]; then
      OSBOX_INSTALLMODE="dev"
  else
      OSBOX_INSTALLMODE="prod"
  fi
  #
  echo "#!/bin/bash">/etc/osbox/.setupconf
  echo "OSBOX_BIN_USR=$OSBOX_BIN_USR">>/etc/osbox/.setupconf
  echo "OSBOX_INSTALLMODE=$OSBOX_INSTALLMODE">>/etc/osbox/.setupconf

fi

#echo "END $OSBOX_INSTALLMODE $OSBOX_BIN_USR"
#exit 1

#SCRIPT_FILENAME=""
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
   SCRIPT_FILENAME="installerservice.sh"
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


docker_container_isrunning(){
    docker ps|grep $1 >/dev/null 2>&1
}

docker_container_exists(){
    docker container ls -a|grep $1 >/dev/null 2>&1
}

docker_image_exists(){
    docker image ls|grep $1 >/dev/null 2>&1
}

docker_pull(){
    #log "docker pull $1"
    docker pull $1 >/dev/null 2>&1
}

docker_stop(){
    #log "docker stop $1"
    docker stop $1 >/dev/null 2>&1
}

docker_rm(){
    #log "docker rm $1"
    docker rm $1 >/dev/null 2>&1
}

## type forking
## simple
osbox_listener_service(){
    echo "[Unit]">/etc/systemd/system/osbox-listener.service
    echo "Description=osbox-listener-service">>/etc/systemd/system/osbox-listener.service
    echo "After=network.target">>/etc/systemd/system/osbox-listener.service
    #echo "StartLimitIntervalSec=4">>/etc/systemd/system/osbox-listener.service
    echo "">>/etc/systemd/system/osbox-listener.service
    echo "[Service]">>/etc/systemd/system/osbox-listener.service
    echo "Type=simple">>/etc/systemd/system/osbox-listener.service
    echo "PIDFile=/run/osbox-listener">>/etc/systemd/system/osbox-listener.service
    echo "Restart=on-abort">>/etc/systemd/system/osbox-listener.service
    #echo "RestartSec=30">>/etc/systemd/system/osbox-listener.service
    echo "User=root">>/etc/systemd/system/osbox-listener.service
    echo "TimeoutStartSec=1">>/etc/systemd/system/osbox-listener.service
    echo "TimeoutStopSec=1">>/etc/systemd/system/osbox-listener.service

    echo "ExecStart=bash /usr/local/osbox/bin/listen.sh>/dev/null 2>&1 ">>/etc/systemd/system/osbox-listener.service
    echo "KillSignal=SIGKILL">>/etc/systemd/system/osbox-listener.service
    #echo "TasksMax=10">>/etc/systemd/system/osbox-listener.service
    echo "[Install]">>/etc/systemd/system/osbox-listener.service
    echo "WantedBy=multi-user.target">>/etc/systemd/system/osbox-listener.service

    systemctl enable osbox-listener


}



disable_installer(){
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/disable_installer.sh
}

enable_avahi(){
  #log "enabling avahi"
  cp /usr/local/osbox/lib/avahi/osbox.service /etc/avahi/services
  #systemctl restart avahi-daemon.service
}



create_database(){
  # check if sqlite3 db exists.
  #
  #  /host/etc/osbox/master.db
  #  /host/etc/osbox/osbox.db
  if [ ! -f /etc/osbox/osbox.db ];then
    touch /etc/osbox/osbox.db
    sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
    sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( 'osbox.db created' );"


  fi

}








docker_run_composer(){
  #log "docker_run_composer..."
  docker run --rm --name osbox-composer --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install >/dev/null 2>&1
}
docker_run_swoole(){
  #log "Starting  docker container"
  docker run -d --name osbox-core --env AUTORELOAD_PROGRAMS="swoole" --env AUTORELOAD_ANY_FILES=0 --restart unless-stopped -v /usr/local/osbox/project/sw-osbox-core/src/www:/var/www  -v /var/osbox:/host/osbox -v /etc:/host/etc -p 81:9501 jerryhopper/swoole:4.5.4-php7.3
}






install_docker(){
  #log "Installing docker"
  /boot/dietpi/dietpi-software install 162 --unattended >/dev/null 2>&1
}






















sleep 15
log "Starting osbox-installer-service"

# check if dietpi is installed completely
if [ -f /boot/dietpi/.installed ] ; then

  INSTALLSTAGE="$(</boot/dietpi/.install_stage)"
  if [  $INSTALLSTAGE = "2" ]; then

      # Check if docker is available.
      if ! is_command docker ; then
          # Docker is not available.
          log "Docker is not available"
          # checking if "apt" is running
          if is_running apt; then
                log "Apt is running, exit!"
                exit
          else
                if install_docker; then
                  echo "docker install ok"
                else
                  log "installation of docker failed!  rebooting!"
                  exit 1
                fi

                exit
          fi
      else
          # Docker is available.
          if ! docker_image_exists "composer"; then
              docker_pull "composer"
          fi

          # Check vendor directory.
          if [ ! -d /usr/local/osbox/project/sw-osbox-core/src/www/vendor ]; then
              echo "No vendor directory!"
              if ! docker_run_composer ; then
                echo "Composer failed?"
              else
                echo "Composer success"
              fi
          fi

          # check if image exists
          if docker_image_exists "jerryhopper/swoole"; then
              # check if container exists
              if docker_container_exists "osbox-core"; then
                  # check if container is running
                  if docker_container_isrunning "osbox-core"; then
                      # stop the running container.
                      docker_stop "osbox-core"
                  fi
                  # remove the stopped container
                  docker_rm "osbox-core"
              fi
          fi

          docker_pull "jerryhopper/swoole:4.5.4-php7.3"

          #enable_pipe

          # check if container exists
          if ! docker_container_exists "osbox-core"; then
              log "osbox-core container is not available."
              docker_run_swoole
          else
              docker_stop "osbox-core"
              docker_rm "osbox-core"
          fi


          # check if container is running.
          if docker_container_isrunning "osbox-core"; then
              log "osbox-core is running"

              enable_avahi
              #log "/boot/dietpi/func/change_hostname osbox"
              log "$(bash /boot/dietpi/func/change_hostname osbox)"
              #sleep 1

              #log "Enable listener-service and disable installer-service"
              osbox_listener_service

              #systemctl enable osbox-installer.service
              #nohup bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/disable_installer.sh &

              #sleep 1
              if ! "$(hostname)" = "osbox"; then
                log "rebooting!"
                /sbin/reboot
              fi

          fi

          ## docker exists
          #log "Docker exists"

          exit
      fi
  else
        log "install-state is not 2. is installer busy?"
        sleep 10
  fi
fi
