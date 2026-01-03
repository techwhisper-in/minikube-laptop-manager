#!/bin/bash
set -euo pipefail

PROFILE="laptop-cluster"
K8S_VERSION="v1.30.2"
MEMORY_PER_NODE=3072
CPUS_PER_NODE=2
DISK_SIZE="40g"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Run with sudo${NC}"
    exit 1
  fi
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_packages() {
  require_root
  echo -e "${GREEN}🔧 Installing required packages...${NC}"

  apt update

  if ! cmd_exists docker; then
    apt install -y docker.io
    systemctl enable --now docker
    usermod -aG docker "$SUDO_USER"
  fi

  if ! cmd_exists kubectl; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    install kubectl /usr/local/bin/kubectl
    rm kubectl
  fi

  if ! cmd_exists minikube; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
  fi

  echo -e "${YELLOW}ℹ Logout & login once if Docker was newly installed${NC}"
}

create_cluster() {
  echo -e "${GREEN}🚀 Creating Kubernetes cluster...${NC}"

  minikube start \
    --profile="$PROFILE" \
    --driver=docker \
    --container-runtime=containerd \
    --nodes=3 \
    --kubernetes-version="$K8S_VERSION" \
    --memory="$MEMORY_PER_NODE" \
    --cpus="$CPUS_PER_NODE" \
    --disk-size="$DISK_SIZE"

  minikube addons enable ingress -p "$PROFILE"
  kubectl wait --for=condition=Ready nodes --all --timeout=300s

  echo -e "${GREEN}✅ Cluster ready${NC}"
  kubectl get nodes
}

setup_autostop() {
  echo -e "${GREEN}🛑 Enabling auto-STOP on logout/shutdown${NC}"

  mkdir -p ~/.local/bin ~/.config/systemd/user

  cat > ~/.local/bin/minikube-safe-stop.sh <<EOF
#!/bin/bash
/usr/local/bin/minikube status -p $PROFILE >/dev/null 2>&1 || exit 0
/usr/local/bin/minikube stop -p $PROFILE
EOF

  chmod +x ~/.local/bin/minikube-safe-stop.sh

  cat > ~/.config/systemd/user/minikube-safe-stop.service <<EOF
[Unit]
Description=Stop Minikube on logout
Before=exit.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/minikube-safe-stop.sh

[Install]
WantedBy=default.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable minikube-safe-stop.service

  echo -e "${GREEN}✅ Auto-STOP enabled${NC}"
}

setup_autostart() {
  echo -e "${GREEN}▶ Enabling auto-START after login${NC}"

  mkdir -p ~/.config/systemd/user

  cat > ~/.config/systemd/user/minikube-autostart.service <<EOF
[Unit]
Description=Start Minikube after login
After=default.target docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minikube start -p $PROFILE

[Install]
WantedBy=default.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable minikube-autostart.service

  echo -e "${GREEN}✅ Auto-START enabled${NC}"
}

remove_autostop() {
  echo -e "${YELLOW}🧹 Removing auto-STOP${NC}"

  systemctl --user disable minikube-safe-stop.service 2>/dev/null || true
  systemctl --user stop minikube-safe-stop.service 2>/dev/null || true

  rm -f ~/.config/systemd/user/minikube-safe-stop.service
  rm -f ~/.local/bin/minikube-safe-stop.sh

  systemctl --user daemon-reload

  echo -e "${GREEN}✅ Auto-STOP removed${NC}"
}

remove_autostart() {
  echo -e "${YELLOW}🧹 Removing auto-START${NC}"

  systemctl --user disable minikube-autostart.service 2>/dev/null || true
  systemctl --user stop minikube-autostart.service 2>/dev/null || true

  rm -f ~/.config/systemd/user/minikube-autostart.service

  systemctl --user daemon-reload

  echo -e "${GREEN}✅ Auto-START removed${NC}"
}

desktop_shortcut() {
  echo -e "${GREEN}🖥 Creating desktop shortcut${NC}"

  mkdir -p ~/.local/share/applications

  cat > ~/.local/share/applications/minikube.desktop <<EOF
[Desktop Entry]
Name=Minikube Cluster
Comment=Start Kubernetes Cluster
Exec=gnome-terminal -- bash -c "minikube start -p $PROFILE; read -p 'Press Enter to close...'"
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Development;
EOF

  echo -e "${GREEN}✅ Desktop shortcut created${NC}"
}

delete_cluster() {
  echo -e "${YELLOW}⚠ Deleting cluster ONLY${NC}"
  read -rp "Type DELETE to confirm: " C
  [[ "$C" == "DELETE" ]] || exit 1

  minikube delete -p "$PROFILE"

  echo -e "${GREEN}✅ Cluster deleted${NC}"
}

full_wipe() {
  require_root
  echo -e "${RED}🚨 FULL WIPE (everything)${NC}"
  read -rp "Type NUKE to confirm: " C
  [[ "$C" == "NUKE" ]] || exit 1

  minikube delete --all || true
  rm -rf ~/.minikube ~/.kube
  docker system prune -af --volumes

  echo -e "${GREEN}💥 System cleaned completely${NC}"
}

echo -e "${GREEN}
===============================
 Kubernetes Laptop Manager
===============================
${NC}"

echo "1) Install required packages"
echo "2) Create Kubernetes cluster"
echo "3) Enable auto-STOP on logout/shutdown"
echo "4) Enable auto-START after login"
echo "5) Disable auto-STOP"
echo "6) Disable auto-START"
echo "7) Create desktop shortcut"
echo "8) Delete cluster only"
echo "9) FULL WIPE (everything)"
echo "0) Exit"

read -rp "Choose an option: " OPT

case "$OPT" in
  1) install_packages ;;
  2) create_cluster ;;
  3) setup_autostop ;;
  4) setup_autostart ;;
  5) remove_autostop ;;
  6) remove_autostart ;;
  7) desktop_shortcut ;;
  8) delete_cluster ;;
  9) full_wipe ;;
  0) exit 0 ;;
  *) echo -e "${RED}Invalid option${NC}" ;;
esac
