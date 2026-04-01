#!/bin/bash

set -e

echo "🔧 Starting Kubernetes node setup..."

# -----------------------------

# Disable swap

# -----------------------------

echo "🚫 Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# -----------------------------

# Load kernel modules

# -----------------------------

echo "📦 Loading kernel modules..."
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# -----------------------------

# Set sysctl params

# -----------------------------

echo "🌐 Configuring sysctl..."
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# -----------------------------

# Install containerd

# -----------------------------

echo "🐳 Installing containerd..."
sudo apt-get update
sudo apt-get install -y containerd apt-transport-https ca-certificates curl gnupg

# Configure containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# -----------------------------

# Install Kubernetes components

# -----------------------------

echo "☸️ Installing kubeadm, kubelet, kubectl..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key 
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' 
| sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# -----------------------------

# Final status check

# -----------------------------

echo "✅ Setup complete!"
echo "👉 You can now run:"
echo "   sudo kubeadm init   (on master)"
echo "   sudo kubeadm join   (on worker)"
