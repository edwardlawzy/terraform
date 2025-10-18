#!/bin/bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

aws eks update-kubeconfig --region us-east-1 --name edward-wordpress-eks-cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 60

echo "Waiting for ArgoCD to be available..."
until kubectl get service argocd-server -n argocd &>/dev/null; do
    sleep 5
done
echo "ArgoCD API is up."

echo "Patching service argocd-server to type NodePort..."

kubectl patch svc argocd-server -n argocd --type='ClusterIP' -p '{"spec":{"type":"NodePort"}}'

echo "Service type updated. Checking status:"
kubectl get svc argocd-server -n argocd


kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo > /home/ec2-user/adminpass
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 &