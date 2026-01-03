# Kubernetes Laptop Manager (Minikube)

A simple, interactive Bash script to set up and manage a **multi-node Kubernetes cluster on a laptop** using **Minikube + Docker**.

This script is designed for:
- Local Kubernetes development
- Learning and testing multi-node clusters
- Laptop-friendly auto start/stop behavior

---

## ✨ Features

- Installs required tools:
  - Docker
  - kubectl
  - Minikube
- Creates a **3-node Kubernetes cluster**
- Uses **Docker driver + containerd**
- Enables **Ingress addon**
- Automatically starts the cluster after login
- Automatically stops the cluster on logout/shutdown
- Desktop shortcut for quick cluster startup
- Safe cluster deletion
- Full system cleanup option (advanced)

---

## 📦 Prerequisites

- Ubuntu / Debian-based Linux
- Internet access
- `sudo` privileges

> ⚠️ This script installs Docker system-wide if it is not already installed.

---

## 🚀 Getting Started

### 1️⃣ Make the script executable
```bash
chmod +x k8s-laptop.sh
```

### 2️⃣ Run the script
```bash
./k8s-laptop.sh
```

You will see an interactive menu.

---

## 🧭 Menu Options Explained

### 1) Install required packages
Installs:
- Docker (enabled to start automatically on boot)
- kubectl
- Minikube

> 🔔 If Docker is installed for the first time, log out and log back in once.

### 2) Create Kubernetes cluster
Creates a Minikube cluster with:
- 3 nodes
- Kubernetes version: v1.30.2
- Docker driver
- containerd runtime
- Ingress addon enabled

The script waits until all nodes are Ready.

### 3) Enable auto-STOP on logout/shutdown
Stops Minikube automatically when:
- You log out
- The system shuts down

This helps:
- Save battery
- Free system resources
- Avoid leftover background processes

### 4) Enable auto-START after login
Starts the Minikube cluster automatically after user login.

> ℹ️ Docker must already be running (it starts automatically at boot).

### 5) Disable auto-STOP
Removes the automatic Minikube stop behavior.

### 6) Disable auto-START
Removes the automatic Minikube start on login.

### 7) Create desktop shortcut
Creates a desktop launcher to start the Minikube cluster in a terminal window.

### 8) Delete cluster only
Deletes only the Kubernetes cluster for this profile.
- Docker remains installed
- Other Minikube profiles are untouched
- Safe for everyday use

> Requires typing: `DELETE`

### 9) FULL WIPE (everything)
⚠️ **DANGEROUS — USE WITH CARE**

This will:
- Delete all Minikube clusters
- Remove all Kubernetes configs
- Remove all Docker containers, images, volumes, and networks

> Requires typing: `NUKE`

Use this only if you want a complete reset.

---

## 🔁 What Happens on Reboot?

| Component | Behavior |
|-----------|----------|
| Docker | Starts automatically |
| Minikube | Starts after user login (if enabled) |
| Kubernetes nodes | Restored automatically |

---

## 🧪 Verifying the Cluster

After the cluster starts:
```bash
kubectl get nodes
kubectl get pods -A
```

---

## 📁 Default Configuration

| Setting | Value |
|---------|-------|
| Profile name | laptop-cluster |
| Node count | 3 |
| Memory per node | 3072 MB |
| CPUs per node | 2 |
| Disk per node | 40 GB |
| Kubernetes version | v1.30.2 |

---

## 🛠 Customization

You can edit these variables at the top of the script:
```bash
PROFILE="laptop-cluster"
K8S_VERSION="v1.30.2"
MEMORY_PER_NODE=3072
CPUS_PER_NODE=2
DISK_SIZE="40g"
```

---

## 🔧 Useful Minikube Commands

Here are some commonly used Minikube commands for managing your cluster:

### Profile Management
```bash
# List all Minikube profiles
minikube profile list

# View current active profile
minikube profile

# Switch to a different profile
minikube profile <profile-name>

# Start a specific profile
minikube start -p <profile-name>

# Delete a specific profile
minikube delete -p <profile-name>
```

### Cluster IP Address
```bash
# Get Minikube IP address
minikube ip

# Get IP for a specific profile
minikube ip -p <profile-name>

# Get service URL (exposes service externally)
minikube service <service-name> --url

# Get service URL for specific namespace
minikube service <service-name> -n <namespace> --url
```

### Node Management
```bash
# List all nodes in the cluster
kubectl get nodes

# List nodes with more details
kubectl get nodes -o wide

# Describe a specific node
kubectl describe node <node-name>

# Check node status and conditions
kubectl get nodes -o custom-columns="NAME:.metadata.name,STATUS:.status.conditions[-1].type,READY:.status.conditions[-1].status"

# Add a new node to the cluster
minikube node add

# Delete a node from the cluster
minikube node delete <node-name>

# List Minikube nodes
minikube node list
```

### Context Management
```bash
# View current kubectl context
kubectl config current-context

# List all available contexts
kubectl config get-contexts

# Switch to a different context
kubectl config use-context <context-name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>

# Rename a context
kubectl config rename-context <old-name> <new-name>

# Delete a context
kubectl config delete-context <context-name>

# View full kubeconfig
kubectl config view
```

### Cluster Status
```bash
# Check Minikube status
minikube status

# Check cluster health
kubectl cluster-info

# View cluster resources
kubectl top nodes
kubectl top pods
```

### Dashboard & Addons
```bash
# Open Kubernetes dashboard
minikube dashboard

# List available addons
minikube addons list

# Enable an addon
minikube addons enable <addon-name>

# Disable an addon
minikube addons disable <addon-name>
```

### SSH & Docker
```bash
# SSH into Minikube VM
minikube ssh

# SSH into specific node
minikube ssh -n <node-name>

# Use Minikube's Docker daemon
eval $(minikube docker-env)

# Reset Docker environment
eval $(minikube docker-env -u)
```

---

## ✅ Recommended Usage Pattern

1. Install packages (once)
2. Create cluster
3. Enable auto-start and auto-stop
4. Use Kubernetes normally
5. Delete cluster when needed

---

## 📌 Notes

- This setup is optimized for laptops
- No background cluster runs unless you log in
- Safe defaults for local development
- Easy to reset or wipe when needed

---

## 📄 License

MIT (or your preferred license)

---

Happy Kubernetes hacking 🚀