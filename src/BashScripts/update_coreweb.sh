#!/bin/bash



cd /usr/local/osbox/project/sw-osbox-core-web
echo "Updating repository for sw-osbox-core-web"
git reset --hard HEAD
git clean -f -d
git pull
