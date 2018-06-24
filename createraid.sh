#!/bin/bash

sudo date; cat /etc/redhat-relase;

echo "Enter number of disks. default is 8:"
read DISKS

##parted -s -a optimal /dev/sd command
##DISKDRIVE=`echo $DISKS | tr "1-8" "c-z"`

ENDDRIVE=$((66 + ${DISKS}))

for i in `seq 67 ${ENDDRIVE}`; do
echo $i
DISKDRIVE=`printf "%b\n" $(printf "%s%x" "\\x" $i)`
DISKDRIVE=`echo $DISKDRIVE | tr "C-Z" "c-z"`
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mklabel gpt   # GPT(GUID Partition Table)
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mkpart primary ext4 1 -1
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- set 1 raid on
done

yes | sudo mdadm --create /dev/md0 --level=raid1 --raid-devices=${DISKS} /dev/sd[c-${DISKDRIVE}]1
