#!/bin/bash



FUSIONAUTH_HOST="$(</etc/osbox/.idp_server)"
OPENID_CONFIG="/etc/osbox/.openid-configuration.json"


FUSIONAUTH_DISCOVERYURL="https://${FUSIONAUTH_HOST}/.well-known/openid-configuration"

#echo $OPENID_CONFIG
#echo $FUSIONAUTH_DISCOVERYURL


http_response=$(curl -s -o $OPENID_CONFIG -X GET -w "%{http_code}" -H "Content-type: application/json" ${FUSIONAUTH_DISCOVERYURL})
if [ $http_response == "000"  ]; then
    # handle error
    echo "{\"error\":\"Unknown error\",\"error_description\":\"curl returned: 000 ${FUSIONAUTH_DISCOVERYURL}\"}"
    exit 1
elif [ $http_response != "200" ]; then
    # handle error
    echo "{\"error\":\"Error\",\"error_description\":\"curl returned: ${http_response} ${FUSIONAUTH_DISCOVERYURL}\"}"
    exit 1
else
    JSON="$(cat $OPENID_CONFIG)"
fi
#echo $JSON

exit

echo $JSON|jq .authorization_endpoint
echo $JSON|jq .device_authorization_endpoint
echo $JSON|jq .jwks_uri
echo $JSON|jq .issuer
echo $JSON|jq .token_endpoint
echo $JSON|jq .userinfo_endpoint
