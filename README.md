# 🚀 Kubernetes Multi-Tier Application Setup (kubeadm)

A step-by-step guide to setting up a **multi-node Kubernetes cluster from scratch using kubeadm** and preparing it for deploying a multi-tier application (React + Node.js + PostgreSQL).

---

## 📌 Project Overview

This project demonstrates:

* 🧩 Control Plane (Master Node)
* ⚙️ Worker Node(s)
* 🌐 Pod Networking using Calico
* 📦 Container Runtime using containerd
* 🔐 Namespace-based isolation (`dev`, `prod`)

---

## 🏗️ Architecture

```text
           +----------------------+
           |   Control Plane      |
           |  (API Server, etcd)  |
           +----------+-----------+
                      |
        ----------------------------
        |                          |
+---------------+        +---------------+
| Worker Node 1 |        | Worker Node 2 |
|   (Pods)      |        |   (Pods)      |
+---------------+        +---------------+
```

---

## ⚙️ Prerequisites

* Ubuntu-based EC2 instances / VMs
* Minimum 2 nodes:

  * 1 Control Plane
  * 1 Worker Node
* SSH access with `sudo` privileges
* Internet access

---

## 🔧 Step 1: Node Preparation

Run on **ALL nodes (control plane + worker nodes)**:

```bash
chmod +x k8s-cluster-setup.sh
./k8s-cluster-setup.sh
```

### 🛠️ This script performs:

* Disables swap
* Loads kernel modules
* Configures sysctl
* Installs containerd
* Installs kubeadm, kubelet, kubectl

---

## ☸️ Step 2: Initialize Control Plane

Run ONLY on control plane:

```bash
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=<CONTROL_PLANE_PRIVATE_IP>
```

---

## 🔑 Step 3: Configure kubectl

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 🌐 Step 4: Install Network (Calico)

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```

---

## 🔗 Step 5: Join Worker Nodes

Run the join command (generated during init) on worker nodes:

```bash
sudo kubeadm join <CONTROL_PLANE_IP>:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH>
```

---

## ✅ Step 6: Verify Cluster

```bash
kubectl get nodes
```

### Expected Output:

```text
NAME              STATUS   ROLES           AGE
control-plane     Ready    control-plane
worker-node       Ready    <none>
```

---

## 📂 Step 7: Create Namespaces

```bash
kubectl create namespace dev
kubectl create namespace prod

kubectl config set-context --current --namespace=dev
```

---

## ⚠️ Important Notes

* ✅ Use `sudo` for:

  * `kubeadm`
  * system-level changes

* ❌ Do NOT use `sudo` with:

  * `kubectl`

* 📌 Run `kubectl` only on control plane node

---

## 🧠 Key Learnings

* Kubernetes architecture (Control Plane vs Worker Nodes)
* Container runtime setup (containerd)
* Cluster networking with Calico
* Handling permissions and kubeconfig
* Namespace-based isolation

---

## 🚀 Next Steps

* Deploy Node.js backend
* Deploy React frontend
* Set up PostgreSQL
* Configure Services & Ingress
* Add CI/CD pipeline

---

## 👨‍💻 Author

---
