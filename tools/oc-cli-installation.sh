#!/bin/bash

# OC CLI Installation : 

# you can also refer to the following link for the latest release of OC : https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/

mkdir -p /opt/openshift/bin
mkdir -p /opt/openshift/source
cd /opt/openshift/source
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

tar -zxvf openshift-client-linux.tar.gz -C /opt/openshift/bin
echo 'export PATH=$PATH:/opt/openshift/bin' >> ~/.bashrc && source ~/.bashrc
echo 'export PATH=$PATH:/opt/openshift/bin' >> ~/.bash_profile

# OC AutoComplete :

oc completion bash > oc_bash_completion
sudo cp oc_bash_completion /etc/bash_completion.d/
