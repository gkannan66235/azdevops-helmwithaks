# Setup of the AKS cluster
az group create -n demogroup -l eastus
az aks create -n demoaks -g demogroup --node-count 2 --generate-ssh-keys

# Once created (the creation could take ~10 min), get the credentials to interact with your AKS cluster
az aks get-credentials -n demoaks -g demogroup

# Create an ACR registry 
az acr create -n demogroupacr -g demogroup -l eastus --sku Basic

# Setup tiller for Helm, we will discuss about this tool later
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# Setup the phippyandfriends namespace, you will deploy later some apps into it
kubectl create namespace phippyandfriends
kubectl create clusterrolebinding default-view --clusterrole=view --serviceaccount=phippyandfriends:default


