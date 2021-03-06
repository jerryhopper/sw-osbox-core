#!/bin/bash

telegram()
{
   SCRIPT_FILENAME="disable_installer.sh"
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

#log "disable_installer.sh"

OSB_INSTALLER="$(systemctl is-enabled osbox-installer.service)"
if [ "$OSB_INSTALLER" = "enabled" ]; then
  log "disable_installer: systemctl stop osbox-installer "
  systemctl stop osbox-installer &
  log "disable_installer: systemctl disable osbox-installer "
  systemctl disable osbox-installer &

fi


