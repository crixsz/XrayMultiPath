#!/bin/bash

# Ask for user input
read -p "Enter username: " username
read -p "Enter expiry date (YYYY-MM-DD): " expiry_date

# Generate a UUID
user_uuid=$(uuidgen)

# Define the new user
new_user=$(jq -n \
                --arg un "$username" \
                --arg ed "$expiry_date" \
                --arg uu "$user_uuid" \
                '{username: $un, expiry_date: $ed, uuid: $uu}')

# Add the new user to the config.json file
jq ".users += [$new_user]" config.json > tmp.json && mv tmp.json config.json

# Add the new user to the none.json file
jq ".users += [$new_user]" none.json > tmp.json && mv tmp.json none.jso