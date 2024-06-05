#!/bin/bash

# OC CLI Installation on Cloud Shell : 

# you can also refer to the following link for the latest release of OC : https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/

echo Home Directory : $HOME
HomeDIR=$HOME

mkdir -p $HomeDIR/opt/openshift/bin
mkdir -p $HomeDIR/opt/openshift/source
cd $HomeDIR/opt/openshift/source
pwd
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

tar -zxvf openshift-client-linux.tar.gz -C $HomeDIR/opt/openshift/bin
ls ../bin 


echo Old Binaries Path : $PATH 

PATH=$PATH:$HomeDIR/opt/openshift/bin 

echo New Added Path : $PATH


echo 'export PATH=$PATH:OCDIR' >> ~/.bashrc
echo 'export PATH=$PATH:OCDIR' >> ~/.bash_profile

sed -i "s/OCDIR/$HomeDIR/g" $HomeDIR/.bashrc
sed -i "s/OCDIR/$HomeDIR/g" $HomeDIR/.bash_profile

source ~/.bashrc
