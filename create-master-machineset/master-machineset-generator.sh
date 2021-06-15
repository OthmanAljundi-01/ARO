#!/bin/bash
set -x


# List Master Nodes and store them inside text file

oc get node -l node-role.kubernetes.io/master  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' > masternodes.txt

for i in `cat masternodes.txt`
do
echo $i
cp -pr general-master-machineset.yaml $i.yaml



CLUSTERAPIMS=$i
sed -i "s/CLUSTERAPIMS/$CLUSTERAPIMS/g" $i.yaml

CLUSTERAPICLUSTER=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.metadata.labels.machine\.openshift\.io\/cluster-api-cluster}'`
sed -i "s/CLUSTERAPICLUSTER/$CLUSTERAPICLUSTER/g" $i.yaml


VMSKU=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.image.sku}'`
sed -i "s/VMSKU/$VMSKU/g" $i.yaml


VMVER=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.image.version}'`
sed -i "s/VMVER/$VMVER/g" $i.yaml


VMREGION=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.location}'`
sed -i "s/VMREGION/$VMREGION/g" $i.yaml


VMZONE=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.zone}'`
sed -i "s/VMZONE/$VMZONE/g" $i.yaml


VMSIZE=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.vmSize}'`
sed -i "s/VMSIZE/$VMSIZE/g" $i.yaml


NETRG=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.networkResourceGroup}'`
sed -i "s/NETRG/$NETRG/g" $i.yaml


DISKSIZE=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.osDisk.diskSizeGB}'`
sed -i "s/DISKSIZE/$DISKSIZE/g" $i.yaml

SAT=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.osDisk.managedDisk.storageAccountType}'`
sed -i "s/SAT/$SAT/g" $i.yaml

PL=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.publicLoadBalancer}'`
sed -i "s/PL/$PL/g" $i.yaml


NODERG=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.resourceGroup}'`
sed -i "s/NODERG/$NODERG/g" $i.yaml


MASTERSUBNET=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.subnet}'`
sed -i "s/MASTERSUBNET/$MASTERSUBNET/g" $i.yaml


MASTERVNET=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.vnet}'`
sed -i "s/MASTERVNET/$MASTERVNET/g" $i.yaml


MSNS=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.metadata.namespace}'`
sed -i "s/MSNS/$MSNS/g" $i.yaml


CSNM=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.credentialsSecret.name}'`
sed -i "s/CSNM/$CSNM/g" $i.yaml


CSNS=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.credentialsSecret.namespace}'`
sed -i "s/CSNS/$CSNS/g" $i.yaml


OFFER=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.image.offer}'`
sed -i "s/OFFER/$OFFER/g" $i.yaml


IMP=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.image.publisher}'`
sed -i "s/IMP/$IMP/g" $i.yaml


ILP=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.internalLoadBalancer}'`
sed -i "s/ILP/$ILP/g" $i.yaml


MI=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.managedIdentity}'`
sed -i "s/MI/$MI/g" $i.yaml


PIP=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.publicIP}'`
sed -i "s/PIP/$PIP/g" $i.yaml


MUDSN=`oc get machine $i -n openshift-machine-api  -o jsonpath='{range .items[*]}{.spec.providerSpec.value.userDataSecret.name}'`
sed -i "s/MUDSN/$MUDSN/g" $i.yaml


done

