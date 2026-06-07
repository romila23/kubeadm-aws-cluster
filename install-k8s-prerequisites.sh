#!/bin/bash

set -e

echo "===== Updating packages ====="
sudo apt update -y
sudo apt upgrade -y

echo "===== Disabling swap ====="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "===== Loading Kubernetes kernel modules ====="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "===== Configuring Kubernetes networking ====="
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system

echo "===== Installing containerd ====="
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

echo "===== Setting SystemdCgroup = true ====="
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "===== Installing Kubernetes tools ====="
sudo apt install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet

echo "===== Verification ====="
free -h
lsmod | grep overlay
lsmod | grep br_netfilter
sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
sudo systemctl status containerd --no-pager
kubeadm version
kubectl version --client
kubelet --version

echo "===== Kubernetes prerequisites completed successfully ====="