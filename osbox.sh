#!/bin/bash

set -e

# is_command function
source /usr/local/osbox/bin/fn/is_command.fn


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

telegram()
{
   SCRIPT_FILENAME="osbox.sh"
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


php(){
  if [ ! -f "$1" ];then
    echo "file does not exist!?"
    exit
  fi
  PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f $1
}


# PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/test2.php
#  /usr/local/osbox/project/sw-osbox-core/src/test2.php
#==============================================================
_USAGETXT="OSBox cli
============================"
_USAGETXT="$_USAGETXT
Usage:
"
_USAGETXT="$_USAGETXT  osbox update  -   (optional parameters : stable/latest)
"
_USAGETXT="$_USAGETXT  osbox reset
"



####################################################################################################
if [ "$1" == "reset" ]; then
  if [ "$2" == "version" ]; then
    echo "0" /etc/osbox/.sw-osbox-bin.version
    echo "0" /etc/osbox/.sw-osbox-core.version
    bash /usr/local/osbox/bin/update.sh
  fi
  if [ "$2" == "database" ]; then
    rm -f /etc/osbox/osbox.db
    bash /usr/local/osbox/bin/update.sh
  fi

  #returnedstatus $? "success" "fail"
  echo "Usage: "
  echo "  osbox reset version  - resets the version and  runs update."
  echo "  osbox reset database - removes the database and runs update."
  echo "  osbox reset  - this message."
  exit
fi









_USAGETXT="$_USAGETXT  osbox installservice   -  (paramaters : enable/disable)
"
####################################################################################################
# osbox install function
if [ "$1" == "service" ]; then
  if [ "$2" == "enable" ]; then
    if [ -f /etc/systemd/system/osbox.service ]; then
        rm -rf /etc/systemd/system/osbox.service
    fi
    # Enable the installer service
    ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
    systemctl enable osbox.service
    exit;
  fi
  if [ "$2" == "disable" ]; then
    if [ -f /etc/systemd/system/osbox.service ]; then
        rm -rf /etc/systemd/system/osbox.service
    fi
    # Enable the installer service
    systemctl daemon-reload
    exit;
  fi
  echo "Usage: "
  echo "  osbox service enable  - Enables the service"
  echo "  osbox service disable - Disables the service"
  exit
fi




# osbox discover function
_USAGETXT="$_USAGETXT  osbox discover   -  (parameters : master/all)
"
if [ "$1" == "discover" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/discover.sh $2 $3 $4
  exit
fi






















if [ "$1" == "reload" ]; then
    systemctl reload osbox.service
    exit;
fi












# osbox network functions
_USAGETXT="$_USAGETXT  osbox database    -  (paramaters : database/reset)
"
if [ "$1" == "database" ]; then
  if [ "$2" == "update" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/database/update.sh
      exit;
  fi
  if [ "$2" == "reset" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/database/reset.sh
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/database/update.sh
      exit;
  fi
  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox database update - updates database"
    echo "  osbox database reset - resets the database"

    exit
  fi
  exit;

fi



# osbox network functions
_USAGETXT="$_USAGETXT  osbox network   -  (paramaters : info/scan/ )
"
if [ "$1" == "network" ]; then


  if [ "$2" == "info" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/info.sh

      exit;
  fi
  if [ "$2" == "scan" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/scan.sh
      exit;
  fi

  source /usr/local/osbox/project/sw-osbox-core/src/sh/network/fn_networktools.sh

  if [ "$2" == "create" ]; then
    if [ "$(nmcli connection show|grep osbox|awk -F ' ' '{print $1}')" == "" ];then
      echo "creating Osbox network adapter...."
      IPNET="$(getNetworkIpNet)"
      echo "IPNET=$IPNET"
      IP="$(echo "${IPNET}"|awk -F '/' '{print $1}')"

      echo "creating..."
      createOsboxInterface "$IPNET"

    fi
  fi

  if [ "$2" == "reset" ]; then
    nmcli connection show|grep osbox>/dev/null
    if [ "$?" == "0" ];then
      echo "Removing Osbox network adapter"
      removeOsboxInterface
    fi

  fi

  if [ "$2" == "list" ]; then
    nmcli connection show
  fi
  # if - interfaces


  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox network info  - returns current network settings"
    echo "  osbox network list  - returns current network settings"
    echo "  osbox network reset  - Removes the network interface"
    echo "  osbox network create - Creates osbox network interface with static IP."
    echo "  osbox network scan  - scans the lan, returns ip/statusses"
    exit
  fi
  exit;
fi








_USAGETXT="$_USAGETXT  osbox logs
"
if [ "$1" == "logs" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/logs.sh
  exit
fi

_USAGETXT="$_USAGETXT  osbox status
"
if [ "$1" == "status" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/status.sh
  exit
fi


## _USAGETXT="$_USAGETXT  osbox update\n"
  # command information
if [ "$1" == "" ]; then
  echo "$_USAGETXT"
  exit
fi
exit;
########################################################################################################################























#########################
#  idle,0,text
#  running,0,text
#  finished,0,text
#########################
# osbox service functions
if [ "$1" == "setup" ]; then
  if [ "$2" == "status" ]; then
      if [ ! -f "/etc/osbox/setup.state" ];then
          echo "idle,0,no setup state">/etc/osbox/setup.state
      else
          echo "$(</etc/osbox/setup.state)"
      fi
      exit
  fi
  if [ "$2" == "ssl" ]; then
      echo "Setting up ssl.";
      bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_ssl.sh
      exit;
  fi
  # module installer
  # module: sw-osbox-core
  # module: sw-osbox-test
  if [ "$2" == "module" ]; then
        # osbox setup module sw-osbox-core
        if [ "$3" != "" ]; then
            if [ "$3" == "sw-osbox-core" ];then
                # set network static!
                sudo echo "running,10,Netwerk configureren.">/etc/osbox/setup.state

                NEWGW="$(osbox network info|awk  -F ',' '{print $4}')"
                NEWIP="$(osbox network scan|grep -m 1 Down|awk  '{print $2}')/$(osbox network info|awk -F ',' '{print $3}'|awk -F '/' '{print $2}')"
                # set_static_ip 10.0.1.4/24 10.0.1.1
                bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_network_static_ip.sh "$NEWIP" "$NEWGW"

#               bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/set_network_static_ip.sh "$(osbox network scan|grep -m 1 Down|awk  '{print $2}')/$(osbox network info|awk -F ',' '{print $3}'|awk -F '/' '{print $2}')" "$(osbox network info|awk  -F ',' '{print $4}')"



            fi
            if [ -f "/usr/local/osbox/project/$3/src/Installation/install-service.sh" ]; then
                sudo echo "running,10,Installatie gestart.">/etc/osbox/setup.state
                bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/create_install_service.sh $3

                exit
            else
                sudo echo "finished,10,cannot find installation script.">/etc/osbox/setup.state
                echo "cant find installationscript: (/usr/local/osbox/project/$3/src/BashScripts/create_install_service.sh)"
                exit 1
            fi
        fi
        echo "Usage: "
        echo "  osbox setup module <modulenaam>"
        exit
  fi


  if [ "$2" == "startstatus" ]; then
      #sudo cp /usr/local/osbox/project/sw-osbox-core/src/Installation/testboot.sh /var/lib/dietpi/dietpi-autostart/custom.sh
      #sudo chmod +x /var/lib/dietpi/dietpi-autostart/custom.sh
      #sudo echo "running,10,Installatie gestart.">/etc/osbox/setup.state

      exit
  fi

  echo "Usage: "
  echo "  osbox setup status"
  echo "  osbox setup module <modulenaam>"

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






if [ "$1" == "update" ]; then
    if [ "$2" == "all" ]; then
        /usr/local/osbox/osbox-update
    fi

    if [ "$2" == "web" ]; then
        bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/update_coreweb.sh|grep HEAD|awk '{print $5}'>/etc/osbox/core-web.v
        echo "$(</etc/osbox/core-web.v)"
    fi

    exit;
fi

if [ "$1" == "reinstall" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/osbox-update.sh
    exit;
fi

if [ "$1" == "reset" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/osbox-reset.sh
    exit;
fi



if [ "$1" == "reboot" ]; then
    nohup sudo reboot & >/dev/null
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
