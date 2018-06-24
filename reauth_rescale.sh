#!/bin/bash
# Create host and hostIP files for chainigng IP address behaviour during VMSS bootup.

echo "Enter HPC username: "
read USER
echo "Enter HPC password: "
read -s PASS

echo "" > /home/${USER}/.ssh/known_hosts
echo "" > /home/$USER/bin/hosts
echo "" > /home/$USER/bin/hostips

IP=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo IP address is $IP
localip=`echo $IP | cut --delimiter='.' -f -3`
nmap -sn $localip.* | grep $localip. | awk '{print $5}' > /home/$USER/bin/hostips
myhost=`hostname -i`
sed -i '/\<'$myhost'\>/d' /home/$USER/bin/hostips
sed -i '/\<10.0.0.1\>/d' /home/$USER/bin/hostips
for NAME in `cat /home/$USER/bin/hostips`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname' >> /home/$USER/bin/hosts;done

echo setting up connection to each node

for NAME in `cat /home/$USER/bin/hostips`; do 
    sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/hosts $USER@$NAME:/home/$USER/
    sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/hostips $USER@$NAME:/home/$USER/
    sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'mkdir /home/'$USER'/.ssh && chmod 700 .ssh'
    sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/.ssh/id_rsa.pub $USER@$NAME:/home/$USER/.ssh/authorized_keys
    sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/.ssh/id_rsa $USER@$NAME:/home/$USER/.ssh/id_rsa
    sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'touch /home/'$USER'/.ssh/config'
    sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'echo "Host *" >  /home/'$USER'/.ssh/config'
    sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'echo StrictHostKeyChecking no >> /home/'$USER'/.ssh/config'
    sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'chmod 400 /home/'$USER'/.ssh/config && chmod 700 /home/'$USER'/.ssh && chmod 640 /home/'$USER'/.ssh/authorized_keys && chmod 600 /home/'$USER'/.ssh/id_rsa'
    sshpass -p $PASS ssh -t -t -o ConnectTimeout=2 $USER@$NAME 'wget https://raw.githubusercontent.com/hirtanak/AHOD-HPC/master/cn-setup.sh -O /home/'$USER'/cn-setup.sh'
    sshpass -p $PASS ssh -t -t -o ConnectTimeout=2 $USER@$NAME 'echo "'$PASS'" | sudo -S sh /home/'$USER'/cn-setup.sh '$IP $USER
done
