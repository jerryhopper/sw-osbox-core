#!/bin/bash


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
