#!/bin/bash

sleep 5


# Disable the installer service.
INSTALLER="$(systemctl is-active osbox-installer.service)"
INSTALLER_SERVICE="$(systemctl is-enabled osbox-installer.service)"

if "$INSTALLER" = "active" ; then
    systemctl stop osbox-installer.service
fi
if "$INSTALLER_SERVICE" = "enabled" ; then
    systemctl disable osbox-installer.service
fi

# ...

sleep 10
