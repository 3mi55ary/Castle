#!/bin/bash
read -p "Enter ip: " ip
read -p "Enter hostname: " hostname
echo
# Write to /etc/hosts
echo "$ip	$hostname" | sudo tee -a /etc/hosts > /dev/null