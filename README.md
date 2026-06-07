# Kubernetes 3-Node Cluster on AWS using Kubeadm

## Architecture

### Control Plane Node
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- etcd

### Worker Nodes
- kubelet
- kube-proxy
- containerd

### Networking
- Calico CNI
- Pod CIDR: 192.168.0.0/16

## Infrastructure

| Node | Instance Type |
|--------|--------|
| Master | t3.medium |
| Worker1 | t3.micro |
| Worker2 | t3.micro |

## Kubernetes Version

```bash
v1.36.1
```

## Prerequisites Installation

```bash
chmod +x install-k8s-prerequisites.sh
./install-k8s-prerequisites.sh
```

## Initialize Control Plane

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

## Install Calico

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml
```

## Join Worker Nodes

```bash
kubeadm join <MASTER-IP>:6443 --token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH>
```

## Verification

```bash
kubectl get nodes
kubectl get pods -A
```

## Cluster Status

```bash
NAME               STATUS   ROLES
master             Ready    control-plane
worker1            Ready
worker2            Ready
```