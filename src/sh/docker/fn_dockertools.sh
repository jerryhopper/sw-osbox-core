#!/bin/bash

source /usr/local/osbox/bin/fn/log.fn
source /usr/local/osbox/bin/fn/is_command.fn
source /usr/local/osbox/bin/fn/DownloadUnpack.fn
source /usr/local/osbox/bin/fn/GetRemoteVersion.fn
source /usr/local/osbox/bin/fn/IsOnline.fn

# commands
#docker exec pihole_container_name pihole updateGravity
#docker exec pihole_container_name pihole -w spclient.wg.spotify.com
#docker exec pihole_container_name pihole -wild example.com

#docker exec sw-osbox-pihole pihole -a -p



# update
#docker pull pihole/pihole
#docker rm -f pihole



runDockerApp(){
    REPO_ORG="$1"
    REPO_REPO="$2"
    INSTALL_PATH="/opt/osbox/$REPO_REPO"

    if [ ! -d $INSTALL_PATH ];then
        echo "App does not exist"
        exit 1
    fi
    docker-compose -f "$INSTALL_PATH/docker-compose.yml" up -d
}

getDockerApp(){
    REPO_ORG="$1"
    REPO_REPO="$2"
    INSTALL_PATH="/opt/osbox/$REPO_REPO"

    if [ -d $INSTALL_PATH ];then
        echo "App already exists"
        #exit 1
    fi
    DownloadUnpack "$REPO_ORG" "$REPO_REPO" "$(GetRemoteVersion "$REPO_ORG" "$REPO_REPO")" "$INSTALL_PATH"
}

stopDockerApp(){
    REPO_ORG="$1"
    REPO_REPO="$2"
    INSTALL_PATH="/opt/osbox/$REPO_REPO"

    docker-compose -f "$INSTALL_PATH/docker-compose.yml" stop
}

removeDockerApp(){
    REPO_ORG="$1"
    REPO_REPO="$2"
    INSTALL_PATH="/opt/osbox/$REPO_REPO"

    docker-compose -f "$INSTALL_PATH/docker-compose.yml" down
    rm -rf $INSTALL_PATH
}
