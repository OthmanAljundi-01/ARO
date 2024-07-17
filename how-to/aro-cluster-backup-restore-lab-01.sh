#!/bin/bash


## Author : Nour Daradkeh 



# This Lab will demonstrate how to backup / restore certain namespaces within ARO cluster using velero

# Note : please make sure to run the commands from WSL, so you have the permission to run az ad commands and keep the velero installation locally .

# Reference Link :

# https://www.ibm.com/docs/en/spp/10.1.7?topic=support-installing-configuring-velero
# https://learn.microsoft.com/en-us/azure/openshift/howto-create-a-backup#create-a-backup-with-velero
# https://learn.microsoft.com/en-us/azure/openshift/howto-create-a-restore#restore-an-azure-red-hat-openshift-4-application





1. Create Storage Account for storing backup :


	AZURE_BACKUP_RESOURCE_GROUP=Velero_Backups
	az group create -n $AZURE_BACKUP_RESOURCE_GROUP --location eastus

	AZURE_STORAGE_ACCOUNT_ID="velero$(uuidgen | cut -d '-' -f5 | tr '[A-Z]' '[a-z]')"
	az storage account create \
		--name $AZURE_STORAGE_ACCOUNT_ID \
		--resource-group $AZURE_BACKUP_RESOURCE_GROUP \
		--sku Standard_GRS \
		--encryption-services blob \
		--https-only true \
		--kind BlobStorage \
		--access-tier Hot

	BLOB_CONTAINER=velero
	az storage container create -n $BLOB_CONTAINER --public-access off --account-name $AZURE_STORAGE_ACCOUNT_ID


2. Create Service Principal and Assign Proper Permissions :


AZURE_ROLE=VeleroAro
az role definition create --role-definition '{
   "Name": "'$AZURE_ROLE'",
   "Description": "Velero related permissions to perform backups, restores and deletions",
   "Actions": [
       "Microsoft.Compute/disks/read",
       "Microsoft.Compute/disks/write",
       "Microsoft.Compute/disks/endGetAccess/action",
       "Microsoft.Compute/disks/beginGetAccess/action",
       "Microsoft.Compute/snapshots/read",
       "Microsoft.Compute/snapshots/write",
       "Microsoft.Compute/snapshots/delete",
       "Microsoft.Storage/storageAccounts/listkeys/action",
       "Microsoft.Storage/storageAccounts/regeneratekey/action",
       "Microsoft.Storage/storageAccounts/read",
       "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
       "Microsoft.Storage/storageAccounts/blobServices/containers/read",
       "Microsoft.Storage/storageAccounts/blobServices/containers/write",
       "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
   ],
   "DataActions" :[
     "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
     "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
     "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
     "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
     "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
   ],
   "AssignableScopes": ["/subscriptions/'$AZURE_SUBSCRIPTION_ID'"]
   }'
   

	az aro list -o table 
	
	AROCluster="ARO Cluster Name"
	ARORG="ARO Cluster Resource Group"

	export AZURE_RESOURCE_GROUP=$(az aro show --name $AROCluster --resource-group $ARORG --query clusterProfile.resourceGroupId -o tsv | cut -d '/' -f 5,5)

	AZURE_SUBSCRIPTION_ID=$(az account list --query '[?isDefault].id' -o tsv)

	AZURE_TENANT_ID=$(az account list --query '[?isDefault].tenantId' -o tsv)

	AZURE_CLIENT_SECRET=$(az ad sp create-for-rbac --name "velero" --role $AZURE_ROLE --query 'password' -o tsv --scopes  /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_BACKUP_RESOURCE_GROUP)
	AZURE_CLIENT_ID=$(az ad sp list --display-name "velero" --query '[0].appId' -o tsv)


	cat << EOF  > ./credentials-velero.yaml
	AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
	AZURE_TENANT_ID=${AZURE_TENANT_ID}
	AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
	AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}
	AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP}
	AZURE_CLOUD_NAME=AzurePublicCloud
	EOF



3. Download and install Velero :


	mkdir velero-media
	cd velero-media
	pwd

	curl -fsSL -o velero-v1.12.4-linux-amd64.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.12.4/velero-v1.12.4-linux-amd64.tar.gz
	ls -l velero-v1.12.4-linux-amd64.tar.gz
	tar -xvf velero-v1.12.4-linux-amd64.tar.gz

	cd velero-v1.12.4-linux-amd64

	VDIR=`pwd`

	./velero install \
	--provider azure \
	--plugins velero/velero-plugin-for-microsoft-azure:v1.8.0 \
	--bucket $BLOB_CONTAINER \
	--secret-file $VDIR/credentials-velero.yaml \
	--backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID \
	--snapshot-location-config apiTimeout=15m \
	--velero-pod-cpu-limit="0" --velero-pod-mem-limit="0" \
	--velero-pod-mem-request="0" --velero-pod-cpu-request="0"





5. create different kubernetes objects inside the namespace such as deployment, route, ... etc :

	oc new-project lab01
	oc new-app --name nginxlab --docker-image=bitnami/nginx
	oc get all 
	oc expose service/nginxlab
	oc get all 



6. Validate the existing kubernete objects inside namespace "lab01" :


    oc get all -n lab01
    oc get all -n lab01 > oc-get-all-lab01.txt
    cat oc-get-all-lab01.txt


 
7. Take the Velero backup: 

            
	velero create backup lab01bk --include-namespaces lab01 --wait -v 9


8. check the velero backup status: 


	oc get backups -n velero lab01bk -o yaml

	velero backup describe lab01bk



9. Take backup for namespace "lab01" :


	oc get all -n lab01 > oc-get-all-lab01.txt



10. Delete the content of namespace "lab01" :


	oc delete ns lab01


11. Restore the content using velero: 


	velero restore create lab01restore01 --from-backup lab01bk


12. Check if  all data in the Lab01 NS was restored as below:


	oc get all -n lab01


13. Compare the data you got in step 11 with the namespace content we took in step 8 :


	cat oc-get-all-lab01.txt
	


