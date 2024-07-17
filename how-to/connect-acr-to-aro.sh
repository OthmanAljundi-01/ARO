
# The following commands will be creating ACR then configure image pull secret in the ARO Cluster



ACRName="aroacrlab"
ACRRG="aro-acr-lab-rg"


az group create --name $ACRRG --location westeurope

az acr create --resource-group $ACRRG --name $ACRName --sku Premium --admin-enabled true --location australiacentral --public-network-enabled

az acr list -o table


az acr credential show -n $ACRName -g $ACRRG -ojson > acrcredential.json


az acr login --name $ACRName

docker pull nginx:1.8
docker tag docker.io/library/nginx:1.8 $ACRName.azurecr.io/nginx:1.8
docker push $ACRName.azurecr.io/nginx:1.8
docker images | grep -i $ACRName


az acr repository list --name $ACRName --output table


DockerUsername=`jq .username acrcredential.json -r`
DockerPassword=`jq .passwords[0].value acrcredential.json -r`


oc create secret docker-registry --docker-server=$ACRName.azurecr.io --docker-username=$DockerUsername --docker-password=$DockerPassword --docker-email=unused acr-secret

oc get secrets acr-secret

oc get secrets acr-secret -oyaml


cat > acrpod1.yaml<< EOF
apiVersion: v1 
kind: Pod 
metadata: 
  labels: 
     app: nginx 
  name: nginx 
spec: 
  containers: 
  - name: nginx 
    image: $ACRName.azurecr.io/nginx:1.8
    ports: 
    - containerPort: 80 
  imagePullSecrets:
  - name: acr-secret
EOF

ls acrpod1.yaml
cat acrpod1.yaml

oc apply -f acrpod1.yaml

oc get pods nginx -w

