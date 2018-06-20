#!/bin/bash
echo ##################################################
echo ############# Compute Node Setup #################
echo ##################################################
IPPRE=$1
USER=$2
GANG_HOST=$3
HOST=`hostname`
if grep -q $IPPRE /etc/fstab; then FLAG=MOUNTED; else FLAG=NOTMOUNTED; fi


if [ $FLAG = NOTMOUNTED ] ; then
    echo $FLAG
    echo installing NFS and mounting
    pkill -9 yum
    sleep 10
    yum install -y -q nfs-utils pdsh
    mkdir -p /mnt/nfsshare
    mkdir -p /mnt/resource/scratch
    chmod 777 /mnt/nfsshare
    systemctl enable rpcbind
    systemctl enable nfs-server
    systemctl enable nfs-lock
    systemctl enable nfs-idmap
    systemctl start rpcbind
    systemctl start nfs-server
    systemctl start nfs-lock
    systemctl start nfs-idmap
    localip=`hostname -i | cut --delimiter='.' -f -3`
    ## echo "$IPPRE:/mnt/nfsshare    /mnt/nfsshare   nfs defaults 0 0" | tee -a /etc/fstab
    echo "$IPPRE:/mnt/resource/scratch    /mnt/resource/scratch   nfs   defaults 0 0" | tee -a /etc/fstab
    mount -a
    df | grep $IPPRE
    impi_version=`ls /opt/intel/impi`
    source /opt/intel/impi/${impi_version}/bin64/mpivars.sh
    ln -s /opt/intel/impi/${impi_version}/intel64/bin/ /opt/intel/impi/${impi_version}/bin
    ln -s /opt/intel/impi/${impi_version}/lib64/ /opt/intel/impi/${impi_version}/lib
    echo "@reboot mkdir -p /mnt/resource/scratch" | tee -a /var/spool/cron/root
    echo "chown ${USER}:${USER} /mnt/resource/scratch" | tee -a /var/spool/cron/root
    echo "@reboot $IPPRE:/mnt/resource/scratch /mnt/resource/scratch" | tee -a /var/spool/cron/root

    echo export I_MPI_FABRICS=shm:dapl >> /home/$USER/.bashrc
    echo export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 >> /home/$USER/.bashrc
    echo export I_MPI_ROOT=/opt/intel/impi/${impi_version} >> /home/$USER/.bashrc
    echo export PATH=/opt/intel/impi/${impi_version}/bin64:$PATH >> /home/$USER/.bashrc
    echo export I_MPI_DYNAMIC_CONNECTION=0 >> /home/$USER/.bashrc
    
    #chmod +x /etc/rc.d/rc.local
    #grep -v "touch" /etc/rc.d/rc.local | sed 's/touch/#touch/g' 
    #echo "sudo mkdir -p /mnt/resource/scratch" >> /etc/rc.d/rc.local
    #echo sleep 10 >> /etc/rc.d/rc.local
    #echo "sudo umount -a" >> /etc/rc.d/rc.local
    #echo "sudo mount -a" >> /etc/rc.d/rc.local
    #echo "exit 0" >> /etc/rc.d/rc.local
    
else
    echo already mounted
    df | grep $IPPRE
fi
