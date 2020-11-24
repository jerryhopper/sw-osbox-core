#!/bin/bash


USAGE="Usage: getDockerApp.sh GITHUBORG GITHUBREPO"


if [ "$1" == "" ];then
  echo "Error! Missing Organization \n$USAGE";
  exit 1
fi

if [ "$2" == "" ];then
  echo "Error! Missing Repository \n$USAGE";
  exit 1
fi

source /usr/local/osbox/project/sw-osbox-core/src/sh/docker/fn_dockertools.sh

getDockerApp "$1" "$2"
#runDockerApp "jerryhopper" "sw-osbox-pihole"
#stopDockerApp "jerryhopper" "sw-osbox-pihole"
#removeDockerApp "jerryhopper" "sw-osbox-pihole"

exit
