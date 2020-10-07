#!/bin/bash



set -e

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}

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



if [ "$1" == "install" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/base_installer.sh
  returnedstatus $? "success" "fail"
fi


if [ "$1" == "update" ]; then
  # if development flag is set
  if [ -f /etc/osbox/dev ]; then
    if ! is_command "docker"; then
      docker stop osbox-core
    fi
    echo "updating sw-osbox-bin via git"
    cd /home/osbox/.osbox/sw-osbox-bin
    git pull
    echo "updating sw-osbox-core via git"
    cd /home/osbox/.osbox/sw-osbox-core
    git pull


  else
    echo "updating sw-osbox-bin via download"
    echo "updating sw-osbox-core via download"
  fi


  docker run --rm --interactive --tty --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install
  echo "docker restart osbox-core"
  if ! is_command "docker"; then
      docker restart osbox-core
  fi


fi

# osbox discover functions
if [ "$1" == "discover" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/discover.sh $2 $3 $4
  exit
fi









# osbox network functions
if [ "$1" == "network" ]; then
  if [ "$2" == "info" ]; then
      bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/networkinfo.sh

      exit;
  fi
  if [ "$2" == "scan" ]; then
      network="$(bash /usr/local/osbox/project/sw-osbox-core/src/BashScripts/networkinfo.sh|awk -F"," '{print $3}')"
      nmap -v -sn $network -oG -|grep Host|awk '{if(NR>1)print}'
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














  # command information
if [ "$1" == "" ]; then
  echo "Usage: "
  echo "  osbox install - installs the application"
  echo "  osbox update  - updates the application"
  echo "  osbox discover - gets network discovery information"
  echo "  osbox network - network functions."
  exit
fi
exit;


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
