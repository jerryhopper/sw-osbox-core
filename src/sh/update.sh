#!/bin/bash


# if development flag is set
if [ -f /etc/osbox/dev ]; then
  if is_command "docker"; then
    if [ "$(docker ps -a|grep osbox-core)" ]; then
      docker stop osbox-core
    fi
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

if is_command "docker"; then
    docker run --rm --interactive --tty --volume /usr/local/osbox/project/sw-osbox-core/src/www:/app composer install

    if [ "$(docker ps -a|grep osbox-core)" ]; then
      echo "docker restart osbox-core"
      docker restart osbox-core
    fi
fi
