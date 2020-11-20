#!/bin/bash

source /usr/local/osbox/bin/fn/log.fn
source /usr/local/osbox/bin/fn/is_command.fn
source /usr/local/osbox/bin/fn/DownloadUnpack.fn
source /usr/local/osbox/bin/fn/GetRemoteVersion.fn
source /usr/local/osbox/bin/fn/IsOnline.fn

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
        exit 1
    fi

    DownloadUnpack "$REPO_ORG" "$REPO_REPO" "$(GetRemoteVersion "$REPO_ORG" "$REPO_REPO")" "$INSTALL_PATH"
}