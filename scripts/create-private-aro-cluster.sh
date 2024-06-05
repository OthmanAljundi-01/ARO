
#!/bin/bash
set -x


# Define Envrinoment Variables :


ARODATE=`date -u +"%F"`

LOCATION=westeurope                         # Location of your ARO cluster
AROCluster="aro-$ARODATE-pri"   # Name of the ARO Cluster
ARORG="$AROCluster-rg"             # Name of Resource Group where you want to create your ARO Cluster

AROVisibility="Private"

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

az aro create --resource-group $ARORG --name $AROCluster --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet --pull-secret @pull-secret.txt --cluster-resource-group $ARONodeRG --apiserver-visibility $AROVisibility  --ingress-visibility $AROVisibility --debug





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

# az aro create --resource-group $ARORG --name $AROCluster --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet --pull-secret @pull-secret.txt --client-id $AROSPID --client-secret $AROSPPass --cluster-resource-group $ARONodeRG --apiserver-visibility $AROVisibility  --ingress-visibility $AROVisibility --debug





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
echo Cluster Creation :  $AROQueryTime
echo
echo The above Creation Time and Parameters can be used in Kusto Queries to Check Cluster Logs (Which can be extracted from Cluster Mainfest as well)
echo
echo




sleep 20







RESOURCEGROUP=$ARORG
VNET=$VNETName
UTILS_VNET="utils-vnet"

# Create the Bastion VNET and subnet :

az network vnet create -g $RESOURCEGROUP -n utils-vnet --address-prefix 10.0.4.0/22 --subnet-name AzureBastionSubnet --subnet-prefix 10.0.4.0/27

az network public-ip create -g $RESOURCEGROUP -n bastion-ip --sku Standard


# Create the Bastion service :


az network bastion create --name bastion-service --public-ip-address bastion-ip --resource-group $RESOURCEGROUP --vnet-name $UTILS_VNET --location $LOCATION

# Get the id for myVirtualNetwork1.
vNet1Id=$(az network vnet show \
  --resource-group $RESOURCEGROUP \
  --name $VNET \
  --query id --out tsv)

# Get the id for myVirtualNetwork2.
vNet2Id=$(az network vnet show \
  --resource-group $RESOURCEGROUP \
  --name $UTILS_VNET \
  --query id \
  --out tsv)

az network vnet peering create \
  --name aro-utils-peering \
  --resource-group $RESOURCEGROUP \
  --vnet-name $VNET \
  --remote-vnet $vNet2Id \
  --allow-vnet-access

az network vnet peering create \
  --name utils-aro-peering \
  --resource-group $RESOURCEGROUP \
  --vnet-name $UTILS_VNET \
  --remote-vnet $vNet1Id \
  --allow-vnet-access


# Create the utility host subnet

az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name $UTILS_VNET \
  --name utils-hosts \
  --address-prefixes 10.0.5.0/24 \
  --service-endpoints Microsoft.ContainerRegistry


# Create the utility host

STORAGE_ACCOUNT="jumpboxdiag$(openssl rand -hex 5)"
az storage account create -n $STORAGE_ACCOUNT -g $RESOURCEGROUP -l $LOCATION --sku Standard_LRS

winpass=$(openssl rand -base64 12)
echo $winpass > winpass.txt

az vm create \
  --resource-group $RESOURCEGROUP \
  --name jumpbox \
  --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest \
  --vnet-name $UTILS_VNET \
  --subnet utils-hosts \
  --public-ip-address "" \
  --admin-username azureuser \
  --admin-password $winpass \
  --authentication-type password \
  --boot-diagnostics-storage $STORAGE_ACCOUNT \
  --generate-ssh-keys

az vm open-port --port 3389 --resource-group $RESOURCEGROUP --name jumpbox









