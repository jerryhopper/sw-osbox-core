#!/bin/bash

ACTION="$1"

allApps=("sw-osbox-pihole" "sw-osbox-phpliteadmin")

if [ "$ACTION" == "list" ]; then
  for f in ${allApps[@]};
  do
      if [ -d "/opt/osbox/$f" ];then
        echo "jerryhopper/$f [installed] ( osbox app remove jerryhoppr/$f)"
      else
        echo "jerryhopper/$f  ( osbox app install jerryhoppr/$f)"
      fi
  done

  exit
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
