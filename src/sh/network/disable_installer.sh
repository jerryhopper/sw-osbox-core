#!/bin/bash

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



log "disable_installer 1"
/bin/systemctl stop osbox-installer >/dev/null 2>&1
sleep 2
log "disable_installer 2"
/bin/systemctl disable osbox-installer >/dev/null 2>&1
sleep 2
log "disable_installer 3"
/bin/systemctl daemon-reload >/dev/null 2>&1
log "Disabling installer service"

exit 0
