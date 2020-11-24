#!/bin/bash

ACTION="$1"

if [ "$ACTION" == "list" ]; then

  exit
fi
if [ "$ACTION" == "available" ]; then
  echo "jerryhopper/sw-osbox-pihole"
  echo "jerryhopper/sw-osbox-sqlitebrowser"
  exit;
fi

APPLICATION="$2"

REPO_ORG="$(echo $APPLICATION|awk -F "/" '{ print $1 }')"
REPO_NAME="$(echo $APPLICATION|awk -F "/" '{ print $2 }')"

echo "$REPO_ORG $REPO_NAME"

source /usr/local/osbox/project/sw-osbox-core/src/sh/getDockerApp.sh
if [ "$ACTION" == "install" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/getDockerApp.sh "$REPO_ORG" "$REPO_NAME"
  sleep
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/runDockerApp.sh "$REPO_ORG" "$REPO_NAME"
  exit
fi

if [ "$ACTION" == "remove" ]; then

  exit
fi
