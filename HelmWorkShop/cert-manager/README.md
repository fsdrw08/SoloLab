# Install cert-manager
# install the cert-manager CustomResourceDefinition resources (change the version refer from https://cert-manager.io/docs/installation/supported-releases/)
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.0/cert-manager.crds.yaml
# Create the namespace for cert-manager
kubectl create namespace cert-manager
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  # --version v1.5.0 
# have a check
kubectl get pods --namespace cert-manager