#!/bin/bash

set -x

SHARE_HOME=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
SHARE_DATA=$4
echo $SHARE_HOME,$LICIP,$HOST,$DOWN

wget -q https://hirostpublicshare.blob.core.windows.net/solvers/STAR-CCM%2B12.04.010_01_linux-x86_64.tar.gz -O $SHARE_DATA/INSTALLERS/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz
wget -q http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/runAndRecord.java -O $SHARE_DATA/benchmark/runAndRecord.java
wget -q http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/$DOWN -O $SHARE_DATA/benchmark/$DOWN

tar -xf $SHARE_DATA/benchmark/$DOWN -C $SHARE_DATA/benchmark
tar -xzf $SHARE_DATA/INSTALLERS/STAR-CCM+12.04.010_01_linux-x86_64.tar.gz -C $SHARE_DATA/INSTALLERS/

cd $SHARE_DATA/INSTALLERS/starccm+_12.04.010/

echo export PODKey=$LICIP >> $SHARE_HOME/.bashrc
echo export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com >> $SHARE_HOME/.bashrc
echo export HOSTS=$SHARE_HOME/bin/nodenames.txt
echo export INTELMPI_ROOT=/opt/intel/impi/5.1.3.223 >> $SHARE_HOME/.bashrc
echo export I_MPI_FABRICS=shm:dapl >> $SHARE_HOME/.bashrc
echo export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 >> $SHARE_HOME/.bashrc
echo export I_MPI_ROOT=/opt/intel/compilers_and_libraries_2016.2.223/linux/mpi >> $SHARE_HOME/.bashrc
echo export PATH=$SHARE_DATA/applications/12.04.010/STAR-CCM+12.04.010/star/bin:/opt/intel/impi/5.1.3.223/bin64:$PATH >> $SHARE_HOME/.bashrc
echo export I_MPI_DYNAMIC_CONNECTION=0 >> $SHARE_HOME/.bashrc
echo '$SHARE_DATA/applications/12.04.010/STAR-CCM+12.04.010/star/bin/starccm+ -np 28 -machinefile '$HOSTS' -power -podkey '$PODKey' -batch -rsh ssh -mpi intel -cpubind bandwidth,v -mppflags "-ppn 14 -genv I_MPI_FABRICS shm:dapl -genv I_MPI_DAPL_PROVIDER ofa-v2-ib0 -genv I_MPI_DYNAMIC_CONNECTION 0" $SHARE_DATA/benchmark/*.sim' >> $SHARE_DATA/benchmark/runccm_example.sh

sh $SHARE_DATA/INSTALLERS/starccm+_12.04.010/STAR-CCM+12.04.010_01_linux-x86_64-2.5_gnu4.8.bin -i silent -DINSTALLDIR=$SHARE_DATA/applications -DNODOC=true -DINSTALLFLEX=false

#rm -rf $SHARE_DATA/INSTALLERS/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz
#rm $SHARE_DATA/*.tgz

