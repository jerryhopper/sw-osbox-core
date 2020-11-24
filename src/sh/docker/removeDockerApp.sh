#!/bin/bash

REPO_ORG="$1"
REPO_NAME="$2"

docker stop $REPO_NAME
docker rm $REPO_NAME

rm -rf "/opt/osbox/$REPO_NAME"
