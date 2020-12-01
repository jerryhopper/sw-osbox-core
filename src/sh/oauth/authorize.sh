#!/bin/bash

# Requires Curl & jq
#
# bash ./authorize.sh "89d998a5-aaef-45d0-9765-adf1f3e00c65" "https://idp.surfwijzer.nl/oauth2/device_authorize"


#if [ -z "$1" ];then
#    echo "Missing clientId"
#    exit 1
#else
#    CLIENT_ID="$1"
#fi

#if [ -z "$2" ];then
#    echo "Missing device authorize url"
#    exit 1
#else
#    AUTH_URL="$2"
#fi

#if [ -z "$3" ];then
#  REQPATH="./"
#else
#  REQPATH="$3"
#fi


CLIENT_ID="$(</etc/osbox/.client_id)"
OPENID_CONFIG="$(</etc/osbox/.openid-configuration.json)"



AUTH_URL="$(echo $OPENID_CONFIG|jq -r .device_authorization_endpoint)"

TOKEN_REQUEST="/etc/osbox/tokenrequest.json"


AUTH_FILE="/etc/osbox/.authorization"

# check if file exists.
if [ -f $AUTH_FILE ]; then
  echo "Device already authorized"
  exit 1
fi





http_response=$(curl -s -o $TOKEN_REQUEST -X POST -F "client_id=${CLIENT_ID}" -F "scope=offline_access" -w "%{http_code}" ${AUTH_URL})
if [ $http_response == "000"  ]; then
    # handle error
    echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 000 $AUTH_URL \"}"
    exit 1
elif [ $http_response == "404" ]; then
    echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 404 $AUTH_URL \"}"
    exit 1
elif [ $http_response != "200" ]; then
    # handle error
    echo "$(cat $TOKEN_REQUEST)"
    rm $FILE
    exit 1
else
    JSON="$(cat $TOKEN_REQUEST)"
    #rm $TOKEN_REQUEST
fi
echo $JSON

exit 0

VERIFICATION_CODE=$(echo $JSON|jq -r .user_code)
VERIFICATION_URL=$(echo $JSON|jq -r .verification_uri)
VERIFICATION_URL_COMPLETE=$(echo $JSON|jq -r .verification_uri_complete)
DEVICE_CODE=$(echo $JSON|jq -r .device_code)
EXPIRES=$(echo $JSON|jq -r .expires_in)
INTERVAL=$(echo $JSON|jq -r .interval)
