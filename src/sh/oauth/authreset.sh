#!/bin/bash

TOKEN_REQUEST="/etc/osbox/tokenrequest.json"
AUTH_FILE="/etc/osbox/.authorization"


# check if request file exists.
if [ -f $TOKEN_REQUEST ]; then
  rm -f $TOKEN_REQUEST
fi

if [ -f $AUTH_FILE ]; then
  rm -f $AUTH_FILE
fi

exit;
