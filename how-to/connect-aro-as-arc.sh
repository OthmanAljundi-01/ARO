Connect the ARO Cluster as ARC Cluster :


Connect the Cluster as ARC : https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli%2Cazure-cloud#prerequisites

Enabling : https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-enable-arc-enabled-clusters?tabs=create-cli%2Cverify-portal%2Cmigrate-cli

Disabling : https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-enable-arc-enabled-clusters?tabs=create-cli%2Cverify-portal%2Cmigrate-cli#delete-extension-instance

Continer Insights ConfigMap :

	wget https://raw.githubusercontent.com/microsoft/Docker-Provider/ci_prod/kubernetes/container-azm-ms-agentconfig.yaml


Connect the Cluster as ARC Cluster :


	az extension add --name connectedk8s
	az extension update --name connectedk8s


	az provider register --namespace Microsoft.Kubernetes
	az provider register --namespace Microsoft.KubernetesConfiguration
	az provider register --namespace Microsoft.ExtendedLocation

	az provider show -n Microsoft.Kubernetes -o table
	az provider show -n Microsoft.KubernetesConfiguration -o table
	az provider show -n Microsoft.ExtendedLocation -o table

	az aro list -o table 

	# 
	# Login into the Cluster using oc cli or kubectl
	#
	
	az group create --name AzureArcAROElevate --location uksouth --output table

	az connectedk8s connect --name AzureArcAROElevate01 --resource-group AzureArcAROElevate --debug

	az connectedk8s list -o table

	helm list -A

	oc get ns | grep -i arc

	oc get all -n azure-arc
	oc get all -n azure-arc-release



List Log Analytics Workspace :


	az resource list --resource-type Microsoft.OperationalInsights/workspaces -o json
	az resource list --resource-type Microsoft.OperationalInsights/workspaces --query [].id





Enable the monitoring extension on the connected ARC Cluster : ( Defult Log Analytics Workspace )


	az k8s-extension create --name azuremonitor-containers --cluster-name AzureArcAROElevate01 --resource-group AzureArcAROElevate --cluster-type connectedClusters --extension-type Microsoft.AzureMonitor.Containers --configuration-settings amalogs.useAADAuth=false --debug



Enable the monitoring extension on the connected ARC Cluster : ( Specific Log Analytics Workspace ) 
# Added by :  Adam Sharif

	az k8s-extension create --name azuremonitor-containers --cluster-name AzureArcAROElevate01 --resource-group AzureArcAROElevate --cluster-type connectedClusters --extension-type Microsoft.AzureMonitor.Containers --configuration-settings logAnalyticsWorkspaceResourceID=<armResourceIdOfExistingWorkspace> --configuration-settings amalogs.useAADAuth=false --debug




Show the Extension is installed :


	az k8s-extension show --name azuremonitor-containers --cluster-name AzureArcAROElevate01 --resource-group AzureArcAROElevate --cluster-type connectedClusters -n azuremonitor-containers

Get AMA Pods :

    oc get pods -n kube-system -l dsName=ama-logs-ds


List Helm Charts :

	helm list -A 



