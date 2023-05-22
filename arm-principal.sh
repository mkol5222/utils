#!/bin/bash

PREFIX="arm-cpp-owner"
ROLE="Owner"

RND=$(xxd  -l 4 -p /dev/urandom)
# create and note deployment credentials, where relevant
SUBSCRIPTION_ID=$(az account list -o json | jq -r '.[]|select(.isDefault)|.id')
echo "Subscription: $SUBSCRIPTION_ID"
echo "SP name: $PREFIX-$RND"

# note credentials for config
AZCRED=$(az ad sp create-for-rbac -n "$PREFIX-$RND" --role="$ROLE" --scopes="/subscriptions/$SUBSCRIPTION_ID")
# echo "$AZCRED" | jq .
CLIENT_ID=$(echo "$AZCRED" | jq -r .appId)
CLIENT_SECRET=$(echo "$AZCRED" | jq -r .password)
TENANT_ID=$(echo "$AZCRED" | jq -r .tenant)

echo
cat << EOF
client_secret = "$CLIENT_SECRET"
client_id = "$CLIENT_ID"
tenant_id = "$TENANT_ID"
subscription_id = "$SUBSCRIPTION_ID"
EOF

echo

op item create --category=login --title="$PREFIX" --vault='Personal' \
		"client_secret=$CLIENT_SECRET" \
		"client_id[text]=$CLIENT_ID" \
        "tenant_id[text]=$TENANT_ID" \
        "subscription_id[text]=$SUBSCRIPTION_ID" 

