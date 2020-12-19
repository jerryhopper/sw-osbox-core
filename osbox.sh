#!/bin/bash

set -e

# is_command function
source /usr/local/osbox/bin/fn/is_command.fn


BACKEND_HOST="$(</etc/osbox/.backendhost)"
DEVICEID="$(</etc/osbox/.deviceID)"


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



if [ ! -f /etc/osbox/.deviceID ];then
    echo -n "$(cat /proc/sys/kernel/random/uuid)">/etc/osbox/.deviceID
fi


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

_USAGETXT="$_USAGETXT  osbox setregistered
"
if [ "$1" == "setregistered" ];then
  # remove from unregistered-devices db
  ETH1="$(osbox network osbox)"
  echo "$ETH1"|awk -F "," '{ print $1 }'


  exit 0
fi


_USAGETXT="$_USAGETXT  osbox unregistered
"
if [ "$1" == "unregistered" ];then
  #echo "$BACKEND_HOST/api/unregistereddevice"
  # ping unregistered-device endpoint with local ips
  ETH0="$(osbox network info)"
  ETH1="$(osbox network osbox)"

  curl -H "User-Agent: OSBox" -X POST -F "eth0=$ETH0" -F "eth1=$ETH1" -F "id=$DEVICEID"  "$BACKEND_HOST/api/unregistereddevice"

  #echo $ETH1

  exit
fi

if [ "$1" == "getssl" ];then

  bash /usr/local/osbox/project/sw-osbox-core/src/sh/getssl.sh
  exit;
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






# osbox discover function
_USAGETXT="$_USAGETXT  osbox auth
"
if [ "$1" == "auth" ]; then

  if [ "$2" == "request" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh authorize
    exit;
  fi
  if [ "$2" == "poll" ]; then
    if [ "$3" == "once" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh poll once
    else
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh poll
    fi

    exit;
  fi
  if [ "$2" == "reset" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh reset
    exit;
  fi
  if [ "$2" == "renew" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh renew
    exit;
  fi
  if [ "$2" == "setClientid" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh setClientid $3
    exit;
  fi
  if [ "$2" == "setDiscovery" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh setDiscovery $3
    exit;
  fi


  echo "Usage: "
  echo "  osbox auth request  - Request authorization"
  echo "  osbox auth poll - Poll for authorization "
  echo "  osbox auth renew - Renews token"
  echo "  osbox auth reset - Resets to no owner"
  echo "  osbox auth setClientid <CLIENT_ID> - Set clientid"
  echo "  osbox auth setDiscovery <DISCOVERY_URL> - Set discovery url"


  bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh setClientid "$(</etc/osbox/.client_id)"
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/deviceauth.sh setDiscovery "$(</etc/osbox/.idp_server)/.well-known/openid-configuration"

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
_USAGETXT="$_USAGETXT  osbox avahi   -  (paramaters : ? )
"
if [ "$1" == "avahi" ]; then
  if [ "$2" == "set" ]; then
      #bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/osboxinfo.sh
      osbox network create

      STATICIP="$(osbox network osbox|awk -F ',' '{ print $1 }')"

      echo '<?xml version="1.0" standalone="no"?><!--*-nxml-*-->'>/etc/avahi/services/osbox.service
      echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">' >>/etc/avahi/services/osbox.service
      echo '<service-group>'>>/etc/avahi/services/osbox.service
      echo '  <name replace-wildcards="yes">Unconfigured OsBox device on %h</name>'>>/etc/avahi/services/osbox.service
      echo '  <service protocol="ipv4">'>>/etc/avahi/services/osbox.service
      echo '    <type>_osbox._tcp</type>'>>/etc/avahi/services/osbox.service
      echo '    <domain-name>local</domain-name>'>>/etc/avahi/services/osbox.service
      echo '    <port>81</port>'>>/etc/avahi/services/osbox.service
      echo "    <txt-record>ssl=$STATICIP</txt-record>">>/etc/avahi/services/osbox.service
      echo '  </service>'>>/etc/avahi/services/osbox.service
      echo '</service-group>'>>/etc/avahi/services/osbox.service

      exit;
  fi
  if [ "$2" == "unset" ]; then
      #bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/osboxinfo.sh

      #STATICIP="$(osbox network osbox|awk -F ',' '{ print $1 }')"

      echo '<?xml version="1.0" standalone="no"?><!--*-nxml-*-->'>/etc/avahi/services/osbox.service
      echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">'>>/etc/avahi/services/osbox.service
      echo '<service-group>'>>/etc/avahi/services/osbox.service
      echo '  <name replace-wildcards="yes">Unconfigured OsBox device on %h</name>'>>/etc/avahi/services/osbox.service
      echo '  <service protocol="ipv4">'>>/etc/avahi/services/osbox.service
      echo '    <type>_osbox._tcp</type>'>>/etc/avahi/services/osbox.service
      echo '    <domain-name>local</domain-name>'>>/etc/avahi/services/osbox.service
      echo '    <port>81</port>'>>/etc/avahi/services/osbox.service
      echo "    <txt-record>ssl=false</txt-record>">>/etc/avahi/services/osbox.service
      echo '  </service>'>>/etc/avahi/services/osbox.service
      echo '</service-group>'>>/etc/avahi/services/osbox.service

      exit;
  fi

  exit;
fi




# osbox network functions
_USAGETXT="$_USAGETXT  osbox network   -  (paramaters : info/scan/ )
"
if [ "$1" == "network" ]; then

  if [ "$2" == "osbox" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/osboxinfo.sh

      exit;
  fi
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


# osbox network functions
_USAGETXT="$_USAGETXT  osbox registration
"
if [ "$1" == "registration" ]; then

  if [ "$2" == "start" ]; then
    if [ ! -f /etc/osbox/.authorization ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/discover.sh
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/authorize.sh
    else
      echo "Already authorized"
      exit 1
    fi

    exit;
  fi

  if [ "$2" == "check" ]; then
    bash /usr/local/osbox/project/sw-osbox-core/src/sh/oauth/authpoll.sh
    exit;
  fi

  echo "Usage:"
  echo " - start  ( Start the authorization sequence )"
  echo " - check  ( Start polling the token endpoint )"

  exit;
fi

# osbox network functions
_USAGETXT="$_USAGETXT  osbox app
"
if [ "$1" == "app" ]; then



  if [ "$2" == "list" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/app.sh "list"
      exit;
  fi
  if [ "$2" == "install" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/app.sh "install" $3
      exit;
  fi
  if [ "$2" == "remove" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/sh/app.sh "remove" $3
      exit;
  fi
  # command information
  if [ "$2" == "" ]; then
    echo "Usage: "
    echo "  osbox app list  - returns current applications"
    echo "  osbox install appname  - Install application  X "
    echo "  osbox remove appname  - Stops and removes the application"
    exit
  fi
fi

_USAGETXT="$_USAGETXT  osbox restart
"
if [ "$1" == "restart" ]; then
  kill -9 $(</run/swoole.pid)
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
