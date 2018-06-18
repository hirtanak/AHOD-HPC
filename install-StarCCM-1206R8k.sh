#!/bin/bash
set -x

SHARE_HOME=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
USER=$4
SHARE_DATA=/mnt/resource/scratch
echo $USER,$SHARE_HOME,$LICIP,$HOST,$DOWN,$SHARE_DATA,$USER

# install library
yum install -y libXext.x86_64 libSM.x86_64 libXt

# create directory
mkdir -p $SHARE_DATA/INSTALLERS/starccm+_12.06.010/

#wget -q https://hirostpublicshare.blob.core.windows.net/solvers/STAR-CCM%2B12.04.010_01_linux-x86_64-r8.tar.gz -O $SHARE_DATA/INSTALLERS/STAR-CCM+12.04.010_01_linux-x86_64-r8.tar.gz
wget -q https://storagekhi.blob.core.windows.net/khi2018storage/STAR-CCM%2B12.06.010_01_linux-x86_64-r8.tar.gz -O $SHARE_DATA/INSTALLERS/STAR-CCM+12.06.010_01_linux-x86_64-r8.tar.gz
wget -q https://storagekhi.blob.core.windows.net/khi2018storage/$DOWN -O $SHARE_DATA/benchmark/$DOWN

#wget -q http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/runAndRecord.java -O $SHARE_DATA/benchmark/runAndRecord.java
#wget -q http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/$DOWN -O $SHARE_DATA/benchmark/$DOWN

#tar -xf $SHARE_DATA/benchmark/$DOWN -C $SHARE_DATA/benchmark
tar -zxvf $SHARE_DATA/INSTALLERS/STAR-CCM+12.06.010_01_linux-x86_64-r8.tar.gz -C $SHARE_DATA/INSTALLERS/

echo "export PODKey=$LICIP" >> /home/$USER/.bashrc
echo "export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com" >> /home/$USER/.bashrc
#export HOSTS=$SHARE_HOME/bin/hosts
echo "export I_MPI_FABRICS=shm:dapl" >> /home/$USER/.bashrc
echo "export I_MPI_DAPL_PROVIDER=ofa-v2-ib0" >> /home/$USER/.bashrc
echo "export I_MPI_ROOT=/opt/intel/compilers_and_libraries_2016.2.223/linux/mpi" >> /home/$USER/.bashrc
echo "export PATH=$SHARE_DATA/applications/12.06.010-R8/STAR-CCM+12.06.010-R8/star/bin:/opt/intel/impi/5.1.3.223/bin64:$PATH" >> /home/$USER/.bashrc
echo "export I_MPI_DYNAMIC_CONNECTION=0" >> /home/$USER/.bashrc
echo "${SHARE_DATA}/applications/12.06.010-R8/STAR-CCM+12.06.010-R8/star/bin/starccm+ -np 28 -machinefile ${SHARE_HOME}/hosts -licpath 1999@flex.cd-adapco.com -power -podkey $PODKey -mpi intel -cpubind bandwidth,v -mppflags '-ppn 14 -genv I_MPI_FABRICS=shm:dapl -genv I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -genv I_MPI_DYNAMIC_CONNECTION=0' -server -rsh ssh ${SHARE_DATA}/benchmark/*.sim" >> $SHARE_DATA/benchmark/runccm_example.sh

#setting privilege 
chmod +x $SHARE_DATA/benchmark/runccm_example.sh
chown $USER:$USER $SHARE_DATA/benchmark/runccm_example.sh
chown $USER:$USER $SHARE_DATA/benchmark/*.sim
chown $USER:$USER $SHARE_DATA/benchmark/*.tgz

cd $SHARE_DATA/INSTALLERS/starccm+_12.06.010/
sh $SHARE_DATA/INSTALLERS/starccm+_12.06.010/STAR-CCM+12.06.010_01_linux-x86_64-2.5_gnu6.2-r8.sh -i silent -DINSTALLDIR=$SHARE_DATA/applications -DNODOC=true -DINSTALLFLEX=false

rm -rf $SHARE_DATA/benchmark/None
#rm -rf $SHARE_DATA/INSTALLERS/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz
#rm $SHARE_DATA/*.tgz
