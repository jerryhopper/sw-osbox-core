#!/bin/bash


if [ "$1" == "update" ]; then
    /usr/local/osbox/osbox-update
    exit;
fi


if [ "$1" =="watch" ]; then
  echo "Watching codebase for changes."
  PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d nohup /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/autoreload-daemon.php & /dev/null
  exit;
fi



echo "Usage: "
echo "osbox update  - updates the codebase."
echo "osbox watch  - watches the codebase for changes and reloads swoole."
