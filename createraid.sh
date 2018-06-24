#!/bin/bash

sudo date; cat /etc/redhat-relase;

echo "Enter number of disks. default is 8:"
read DISKS

ENDDRIVE=$((66 + ${DISKS}))
for i in `seq 67 ${ENDDRIVE}`; do
DISKDRIVE=`printf "%b\n" $(printf "%s%x" "\\x" $i)`
DISKDRIVE=`echo $DISKDRIVE | tr "C-Z" "c-z"`
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mklabel gpt   # GPT(GUID Partition Table)
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mkpart primary ext4 1 -1
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- set 1 raid on
done

yes | sudo mdadm --create /dev/md0 --level=raid1 --raid-devices=${DISKS} /dev/sd[c-${DISKDRIVE}]1

## You can check this command to create file system 
## $ sudo cat /proc/mdstat 
## Personalities : [raid1] 
## md0 : active raid1 sdn1[11] sdm1[10] sdl1[9] sdk1[8] sdj1[7] sdi1[6] sdh1[5] sdg1[4] sdf1[3] sde1[2] sdd1[1] sdc1[0]
##      536737792 blocks super 1.2 [12/12] [UUUUUUUUUUUU]
##      [===>.................]  resync = 15.6% (84170368/536737792) finish=182.8min speed=41255K/sec
##      bitmap: 4/4 pages [16KB], 65536KB chunk
