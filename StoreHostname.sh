#!/bin/bash
read -p "Enter ip: " ip
echo "AD hostname example: DC01 example.local DC01.example.local"
read -p "Enter hostname(s) seperated by a space: " hostname
echo
# Write to /etc/hosts
echo "$ip	$hostname" | sudo tee -a /etc/hosts > /dev/null
