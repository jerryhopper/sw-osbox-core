#!/bin/bash



crt="$(</etc/osbox/.backendhost)/api/localssl?item=cer"
key="$(</etc/osbox/.backendhost)/api/localssl?item=key"
fullchain="$(</etc/osbox/.backendhost)/api/localssl?item=fullchain"

dstdir="/etc/osbox/.ssl"

# /etc/osbox/.ssl/ssl.dockbox.nl.crt

if [ ! -d $dstdir ];then
    mkdir -p $dstdir
fi


wget -nv -q -O "/etc/osbox/.ssl/ssl.dockbox.nl.cer" $crt
if [ "$?" == "0" ];then
  wget -nv -q -O "/etc/osbox/.ssl/ssl.dockbox.nl.key" $key
  if [ "$?" == "0" ];then
      wget -nv -q -O "/etc/osbox/.ssl/ssl.dockbox.nl.fullchain" $fullchain
      exit 0;
  fi
  exit 1
fi

exit 1
