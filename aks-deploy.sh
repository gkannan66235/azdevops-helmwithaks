$rg=demogroup # Resource Group Name
$aks=demoaks # AKS Cluster Name
$acr=demogroupacr # ACR Name



# Setup of the AKS cluster
az group create -n $rg -l eastus
az aks create -n $aks -g $rg --node-count 2 --generate-ssh-keys

# Once created (the creation could take ~10 min), get the credentials to interact with your AKS cluster
az aks get-credentials -n $aks -g $rg

# Create an ACR registry 
az acr create -n $acr -g $rg -l eastus --sku Basic

# Setup tiller for Helm, we will discuss about this tool later
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# Setup the phippyandfriends namespace, you will deploy later some apps into it
kubectl create namespace phippyandfriends
kubectl create clusterrolebinding default-view --clusterrole=view --serviceaccount=phippyandfriends:default

# 1. Grant the AKS-generated service principal pull access to our ACR, the AKS cluster will be able to pull images of our ACR
CLIENT_ID=$(az aks show -g $rg -n $aks --query "servicePrincipalProfile.clientId" -o tsv)
ACR_ID=$(az acr show -n $acr -g $rg --query "id" -o tsv)
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID

# 2. Create a specific Service Principal for our Azure DevOps pipelines to be able to push and pull images and charts of our ACR
registryPassword=$(az ad sp create-for-rbac -n $acr-push --scopes $ACR_ID --role acrpush --query password -o tsv)

# Important note: you will need this registryPassword value later in this blog article in the Create a Build pipeline and Create a Release pipeline sections
echo $registryPassword

# Refer Git Link for app and Helm
# https://github.com/Azure/phippyandfriends
# Refer blog 
# https://cloudblogs.microsoft.com/opensource/2018/11/27/tutorial-azure-devops-setup-cicd-pipeline-kubernetes-docker-helm/
