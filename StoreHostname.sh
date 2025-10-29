#!/bin/bash
read -p "Enter ip: " ip
read -p "Enter hostname(s) seperated by a space: " hostname
echo
# Write to /etc/hosts
echo "$ip	$hostname" | sudo tee -a /etc/hosts > /dev/null
