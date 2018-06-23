#!/bin/bash

echo "Enter Your Sweep Subnet: "
echo "Example: 10.0.0. for 10.0.0.0/24"
read SUBNET

for i in `seq 1 255`; do ping -c 1 ${SUBNET}.$i | tr \\n ' ' | awk '/1 received/ {print $2}'; done
