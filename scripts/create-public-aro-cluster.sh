
#!/bin/bash
set -x


# Define Envrinoment Variables :


ARODATE=`date -u +"%F"`

LOCATION=westeurope                         # Location of your ARO cluster
AROCluster="aro-$ARODATE-pub"   # Name of the ARO Cluster
ARORG="$AROCluster-rg"             # Name of Resource Group where you want to create your ARO Cluster



VNETName="$AROCluster-vnet"                # Name of ARO VNET
VNETAddr="10.0.0.0/22"                  # VNET Address Prefixes

MasterSubNet="$AROCluster-master-subnet"   # Name of ARO Master Subnet
MasterAddr="10.0.2.0/24"                # Master Subnet Address Prefixes

WorkerSubNet="$AROCluster-worker-subnet"   # Name of ARO Worker Subnet
WorkerAddr="10.0.3.0/24"                # Worker Subnet Address Prefixes


ARONodeRG="$AROCluster-mc-rg"	# ARO Cluster Infrastructure Resource Group


# Create ARO Cluster Prerequisites :

az group create --name $ARORG --location $LOCATION

az network vnet create --resource-group $ARORG --name $VNETName --address-prefixes $VNETAddr

az network vnet subnet create --resource-group $ARORG --vnet-name $VNETName --name $MasterSubNet --address-prefixes $MasterAddr --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create --resource-group $ARORG --vnet-name $VNETName --name $WorkerSubNet --address-prefixes $WorkerAddr --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update --name $MasterSubNet --resource-group $ARORG --vnet-name $VNETName --disable-private-link-service-network-policies true


# Create Pull-Secret File : 

# Microsoft Link : https://learn.microsoft.com/en-us/azure/openshift/tutorial-create-cluster#get-a-red-hat-pull-secret-optional
# RedHat Link : https://console.redhat.com/openshift/install/azure/aro-provisioned

touch pull-secret.txt

# edit pull-secret.txt with your pull-secret
# Note : If you don't have pull secret, Please remove the option (--pull-secret @pull-secret.txt) from az aro create command


# Validate ARO Cluster Creation Parameters : ( to make sure that ARO creation process can be applied successfully)

az aro validate --resource-group $ARORG --name $AROCluster --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet --cluster-resource-group $ARONodeRG



# Create ARO Cluster without Predefined SP :

az aro create --resource-group $ARORG --name $AROCluster --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet --pull-secret @pull-secret.txt --cluster-resource-group $ARONodeRG --debug






# This create command can be used when you want to specify ARO SP Client-ID and Secret

# Create ARO SP :


#AROSPDisplayName="$AROCluster-sp"
#az ad sp create-for-rbac --name $AROSPDisplayName --sdk-auth --skip-assignment  > arospinfo.json
#cat arospinfo.json | base64 -w0 > secretJSON.txt
#AROSPID=`jq -r .clientId arospinfo.json`
#AROSPPass=`jq -r .clientSecret arospinfo.json`
#AROSPTENANTID=`jq -r .tenantId arospinfo.json`
#secretJSON=`cat secretJSON.txt`



# Create ARO Cluster with ARO SP :

# az aro create --resource-group $ARORG --name $AROCluster --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet --pull-secret @pull-secret.txt --client-id $AROSPID --client-secret $AROSPPass --cluster-resource-group $ARONodeRG --debug



# List ARO Clusters :

az aro list -o table


# Get Kubeadmin Access :

az aro list-credentials --name $AROCluster --resource-group $ARORG


kubeadminPassword=$(az aro list-credentials --name $AROCluster --resource-group $ARORG --query=kubeadminPassword -o tsv)

kubeadminUsername=$(az aro list-credentials --name $AROCluster --resource-group $ARORG --query=kubeadminUsername -o tsv)

AROAPISrvURL=$(az aro show -g $ARORG -n $AROCluster --query apiserverProfile.url -o tsv)

oc login $AROAPISrvURL -u $kubeadminUsername -p $kubeadminPassword



# Display ARO Cluster Information :

ARORSID=`az aro show -n $AROCluster -g $ARORG  --query id -o tsv`
AROSubID=`echo $ARORSID | cut -d"/" -f3`
ARONodeRGID=`az aro show -n $AROCluster -g $ARORG --query clusterProfile.resourceGroupId -o tsv`
ARONodeRG=`echo $ARONodeRGID | cut -d"/" -f5`

echo
echo Cluster Resource ID : $ARORSID
echo
echo Cluster Subscription ID : $AROSubID
echo 
echo Cluster Resource Group : $ARONodeRG
echo
echo Cluster Infrastructure Resource Group : $ARONodeRG
echo

