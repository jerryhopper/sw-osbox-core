#!/bin/bash


getSSL(){
  crt="https://api.surfwijzer.nl/localssl/ssl.dockbox.nl/ssl.dockbox.nl.crt"
  key="https://api.surfwijzer.nl/localssl/ssl.dockbox.nl/ssl.dockbox.nl.key"
  dstdir="/etc/osbox/.ssl"

  # /etc/osbox/.ssl/ssl.dockbox.nl.crt

  if [ -d $dstdir ];then
      mkdir -p $dstdir
  fi
  wget $crt $dstdir
  wget $key $dstdir

}

getSSL
