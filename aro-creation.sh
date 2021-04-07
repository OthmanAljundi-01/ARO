#!/bin/bash
set -x

LOCATION=eastus                         # Location of your ARO cluster
CLUSTER=oth-aro-02                      # Name of your ARO cluster
RESOURCEGROUP="$CLUSTER-rg"             # Name of Resource Group where you want to create your ARO Cluster


VNETName="$CLUSTER-vnet"                # Name of ARO VNET
VNETAddr="10.1.0.0/22"                  # VNET Address Prefixes

MasterSubNet="$CLUSTER-master-subnet"   # Name of ARO Master Subnet
MasterAddr="10.1.0.0/23"                # Master Subnet Address Prefixes

WorkerSubNet="$CLUSTER-worker-subnet"   # Name of ARO Worker Subnet
WorkerAddr="10.1.2.0/23"                # Worker Subnet Address Prefixes




# Create ARO Cluster Prerequisites :

az group create --name $RESOURCEGROUP --location $LOCATION

az network vnet create --resource-group $RESOURCEGROUP --name $VNETName --address-prefixes $VNETAddr

az network vnet subnet create --resource-group $RESOURCEGROUP --vnet-name $VNETName --name $MasterSubNet --address-prefixes $MasterAddr --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create --resource-group $RESOURCEGROUP --vnet-name $VNETName --name $WorkerSubNet --address-prefixes $WorkerAddr --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update --name $MasterSubNet --resource-group $RESOURCEGROUP --vnet-name $VNETName --disable-private-link-service-network-policies true

az aro create --resource-group $RESOURCEGROUP --name $CLUSTER --vnet $VNETName --master-subnet $MasterSubNet --worker-subnet $WorkerSubNet  --pull-secret @pull-secret.txt

az aro list -o table

az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP

kubeadminPassword=$(az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP --query=kubeadminPassword -o tsv)

kubeadminUsername=$(az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP --query=kubeadminUsername -o tsv)

apiServer=$(az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv)

oc login $apiServer -u $kubeadminUsername -p $kubeadminPassword


