#!/bin/bash


if [ "$1" == "update" ]; then
    /usr/local/osbox/osbox-update
    exit;
fi

if [ "$1" == "reinstall" ]; then
    /usr/local/osbox/project/sw-osbox-core/osbox-update.sh
    exit;
fi

if [ "$1" == "reboot" ]; then
    nohup sudo reboot & >/dev/null
    exit;
fi



if [ "$1" == "watch" ]; then
  echo "Watching codebase for changes."
  PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d nohup /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/autoreload-daemon.php & >/dev/null
  exit;
fi

#
if [ "$1" == "test" ]; then
  echo "Watching codebase for changes."
  PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d nohup /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/test.php
  exit;
fi


# osbox network functions
if [ "$1" == "scheduler" ]; then
  if [ "$2" == "restart" ]; then
    systemctl restart osbox-scheduler
  fi
  if [ "$2" == "start" ]; then
    systemctl start osbox-scheduler
  fi
  if [ "$2" == "stop" ]; then
    systemctl stop osbox-scheduler
  fi

  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox scheduler restart"
    echo "  osbox scheduler start"
    echo "  osbox scheduler stop"


  fi
fi




# osbox network functions
if [ "$1" == "network" ]; then

  # if - interfaces
  if [ "$2" == "if" ]; then

      # osbox if reset
      if [ "$3" == "reset" ]; then
          echo "network reset"
      fi
      # osbox if set <ip>
      if [ "$3" == "set" ]; then
          echo "network set x y z"
      fi

  fi


  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox network if reset  - Resets the network to dhcp"
    echo "  osbox network if set <IP> - Sets the network to static ip."

  fi
  #echo "Watching codebase for changes."
  #PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d nohup /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/test.php
  exit;
fi



echo "Usage: "
echo "  osbox network  - show network functions."
echo "  osbox update  - updates the codebase."
echo "  osbox watch  - watches the codebase for changes and reloads swoole."
echo "  osbox reboot  - reboots the device."
echo "  osbox test  - runs a dev test script"
