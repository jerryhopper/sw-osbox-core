#!/bin/bash

# installation log
log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
}

log "osbox-installer-service"

