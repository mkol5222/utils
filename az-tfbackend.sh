#!/bin/bash

PREFIX="mkoldovcpp"
RESOURCE_GROUP_NAME="$PREFIX-tfstate"
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate 

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location westeurope

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob 

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

echo
echo "resource_group_name  = \"$RESOURCE_GROUP_NAME\""
echo "storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "container_name       = \"$CONTAINER_NAME\""
echo "key                  = \"terraform.tfstate\""

ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv) 

echo export ARM_ACCESS_KEY=$ACCOUNT_KEY
echo 

op item create --category=login --title="az-tfstate-$PREFIX" --vault='Personal' \
		"resource_group_name[text]=$RESOURCE_GROUP_NAME" \
		"storage_account_name[text]=$STORAGE_ACCOUNT_NAME" \
        "container_name[text]=$CONTAINER_NAME" \
        "ARM_ACCESS_KEY=$ARM_ACCESS_KEY"
        