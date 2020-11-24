#!/bin/bash

ACTION="$1"

if [ "$ACTION" == "list" ]; then

  exit
fi
if [ "$ACTION" == "available" ]; then
  echo "jerryhopper/sw-osbox-pihole"
  echo "jerryhopper/sw-osbox-phpliteadmin"
  exit;
fi

APPLICATION="$2"
echo "Application = $APPLICATION"

REPO_ORG="$(echo $APPLICATION|awk -F "/" '{ print $1 }')"
echo "REPO_ORG = $REPO_ORG"

REPO_NAME="$(echo $APPLICATION|awk -F "/" '{ print $2 }')"
echo "REPO_NAME = $REPO_NAME"
#echo "$REPO_ORG $REPO_NAME"


if [ "$ACTION" == "install" ]; then

  bash /usr/local/osbox/project/sw-osbox-core/src/sh/docker/getDockerApp.sh $REPO_ORG $REPO_NAME
  sleep 1
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/docker/runDockerApp.sh $REPO_ORG $REPO_NAME
  exit
fi

if [ "$ACTION" == "remove" ]; then
  bash /usr/local/osbox/project/sw-osbox-core/src/sh/docker/removeDockerApp.sh $REPO_ORG $REPO_NAME
  exit
fi
