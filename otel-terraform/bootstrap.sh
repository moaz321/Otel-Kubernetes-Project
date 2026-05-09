#!/bin/bash

set -ex
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo "Starting bootstrap..."

echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing base tools..."
apt install -y curl wget git apt-transport-https ca-certificates

echo "Installing Docker..."
apt install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Installing kind..."
curl -Lo kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
mv kind /usr/local/bin/kind

echo "Creating kind cluster..."
su - ubuntu -c "kind create cluster --name otel-cluster"

echo "Done setup!"
