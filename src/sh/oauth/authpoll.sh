#!/bin/bash



#if [ -z "$1" ];then
#    echo "Missing clientId"
#    exit 1
#else
#    CLIENT_ID="$1"
#fi

#if [ -z "$2" ];then
#    echo "Missing authorization url"
#    exit 1
#else
#    AUTH_URL="$2"
#fi

#if [ -z "$3" ];then
#    REQPATH="./"
#else
#    REQPATH="$3"
#fi

# override for test

CLIENT_ID="$(</etc/osbox/.client_id)"
DISCOVERY_INFO="$(</etc/osbox/.openid-configuration.json)"


TOKEN_URL="$(echo $DISCOVERY_INFO|jq -r .token_endpoint)"
TOKEN_REQUEST="/etc/osbox/tokenrequest.json"





# check if request file exists.
if [ ! -f $TOKEN_REQUEST ]; then
  echo "No tokenrequest.json?"
  exit 1
fi

# Load the tokenrequest json
JSON="$(<$TOKEN_REQUEST)"


# Extract variables from json
DEVICE_CODE=$(echo "$JSON"|jq -r .device_code)
EXPIRES=$(echo $JSON|jq -r .expires_in)
INTERVAL=$(echo $JSON|jq -r .interval)

# Wait untill authorization has been completed
end=$((SECONDS+EXPIRES))
while [  $SECONDS -lt  $end ] ;  do
    # Pause for the specified time
    sleep $INTERVAL

    AJSON="$(curl -s -X POST -F "client_id=${CLIENT_ID}" -F "device_code=${DEVICE_CODE}" -F "grant_type=urn:ietf:params:oauth:grant-type:device_code" ${TOKEN_URL})"

    HAS_ERROR="$(echo $AJSON|jq -r .error)"
    ACCESS_TOKEN="$(echo $AJSON|jq -r .access_token)"

    if [ "$ACCESS_TOKEN" != "null" ]; then
      echo "$AJSON">/etc/osbox/.authorization
      rm -f $TOKEN_REQUEST
      echo "$AJSON"
      exit 0
    fi

    if [ "$HAS_ERROR" != "authorization_pending" ]; then
      echo "$HAS_ERROR"
      rm -f $TOKEN_REQUEST
      exit 1
    fi

done







exit



ACCESS_TOKEN="$(echo $AJSON|jq -r .access_token)"
EXPIRES_IN="$(echo $AJSON|jq -r .expires_in)"
TOKEN_TYPE="$(echo $AJSON|jq -r .token_type)"
USER_ID="$(echo $AJSON|jq -r .userId)"


exit 0
