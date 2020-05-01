#!/bin/bash

returnedstatus(){
  if [ $1 -eq 0 ]; then
      echo "$2"
      exit 0
    else
      echo "$3" >&2
      exit 1
    fi
    exit
}
#==============================================================

# osbox service functions
if [ "$1" == "setup" ]; then
  if [ "$2" == "status" ]; then
      if [ ! -f "/etc/osbox/setup.state" ];then
          echo "0,no setup state"
      else
          echo "$(</etc/osbox/setup.state)"
      fi
      exit
  fi
  echo "Usage: "
  echo "  osbox setup status"
  exit
fi


# osbox service functions
if [ "$1" == "service" ]; then
  if [ "$2" == "restart" ]; then
    sudo systemctl restart osbox.service
    returnedstatus $? "success" "fail"
  fi
  if [ "$2" == "start" ]; then
    sudo systemctl start osbox.service
    returnedstatus $? "success" "fail"
  fi
  if [ "$2" == "stop" ]; then
    sudo systemctl stop osbox.service
    returnedstatus $? "success" "fail"
  fi
  echo "Usage: "
  echo "  osbox service restart"
  echo "  osbox service start"
  echo "  osbox service stop"
  exit
fi

# osbox scheduler functions
if [ "$1" == "scheduler" ]; then
  if [ "$2" == "restart" ]; then
    sudo systemctl restart osbox-scheduler.service
    returnedstatus $? "success" "fail"
  fi
  if [ "$2" == "start" ]; then
    sudo systemctl start osbox-scheduler.service
    returnedstatus $? "success" "fail"
  fi
  if [ "$2" == "stop" ]; then
    sudo systemctl stop osbox-scheduler.service
    returnedstatus $? "success" "fail"
  fi
  echo "Usage: "
  echo "  osbox scheduler restart"
  echo "  osbox scheduler start"
  echo "  osbox scheduler stop"
  exit
fi


############################################################
############################################################




# osbox network functions
if [ "$1" == "network" ]; then
  if [ "$2" == "info" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/networkinfo.sh

      exit;
  fi
  if [ "$2" == "scan" ]; then
      network="$(bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/networkinfo.sh|awk -F"," '{print $3}')"
      nmap -v -sn $network -oG -|grep Host
      exit;
  fi


  # if - interfaces
  if [ "$2" == "if" ]; then
      # osbox if reset
      if [ "$3" == "reset" ]; then
          echo "network reset"
          bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_network_dynamic_ip.sh
          returnedstatus $? "success" "fail"
      fi
      # osbox if set <ip>
      # bash /usr/lib/osbox/stage/networksetstatic.sh $2 $3 $4 $5
      # bash /usr/lib/osbox/stage/networksetstatic.sh IP SUBN GW $5
      if [ "$3" == "set" ]; then
          if [ "$4" == "" ]; then
              echo "Missing paramaters... example: "
              echo "  osbox network if set 192.168.1.10/24 192.168.1.1"
              exit 1
          fi
          if [ "$5" == "" ]; then
              echo "Missing paramaters... example: "
              echo "  osbox network if set 192.168.1.10/24 192.168.1.1"
              exit 1
          fi
          bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_network_static_ip.sh $4 $5
          returnedstatus $? "success" "fail"

      fi
  fi

  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox network scan  - scans the lan, returns ip/statusses"
    echo "  osbox network info  - returns current network settings"

    echo "  osbox network if reset  - Resets the network to dhcp"
    echo "  osbox network if set <IP/SIZE> <GATEWAY> - Sets the network to static ip."
    exit
  fi
  exit;
fi




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




echo "Usage: "
echo "  osbox network  - show network functions."
echo "  osbox scheduler  - show scheduler functions."
echo "  osbox service  - show service functions."
echo " "
echo "  osbox update  - updates the codebase."
echo "  osbox watch  - watches the codebase for changes and reloads swoole."
echo "  osbox reboot  - reboots the device."
echo "  osbox test  - runs a dev test script"
