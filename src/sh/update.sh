#!/bin/bash


# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


# if development flag is set
if [ -f /etc/osbox/dev ]; then
  if is_command "docker"; then
    if [ "$(docker ps -a|grep osbox-core)" ]; then
      docker stop osbox-core
    fi
  fi
  git stash
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

if is_command "docker"; then
    docker run --rm --interactive --tty --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install

    # enable the pipe listener.
    echo "systemctl restart osbox-listener"
    systemctl restart osbox-listener
    #/usr/bin/nohup /bin/bash /usr/local/osbox/bin/listen.sh > /dev/null &


    if [ "$(docker ps -a|grep osbox-core)" ]; then
      echo "docker restart osbox-core"
      docker restart osbox-core
    fi
fi

bash /usr/local/osbox/project/sw-osbox-core/src/sh/database/update.sh
