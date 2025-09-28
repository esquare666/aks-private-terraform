#!/bin/bash
# jumpbox-init.sh
# Initialization script for jumpbox VM to access private AKS cluster

set -e

# Update system
apt-get update && apt-get upgrade -y

# Install required packages
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
usermod -aG docker azureuser

# Install additional tools
# k9s for cluster management
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_x86_64.tar.gz | tar xz -C /tmp
sudo mv /tmp/k9s /usr/local/bin/

# kubens and kubectx for context switching
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

# Install Azure PowerShell (optional)
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y powershell

# Create useful aliases and functions
cat << 'EOF' >> /home/azureuser/.bashrc

# Kubernetes aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'

# Azure aliases
alias az-login='az login --use-device-code'
alias az-sub='az account show --output table'

# Functions for AKS management
function get-aks-creds() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: get-aks-creds <resource-group> <cluster-name>"
        return 1
    fi
    az aks get-credentials --resource-group "$1" --name "$2" --overwrite-existing
}

function aks-connect() {
    get-aks-creds "${resource_group_name}" "${aks_cluster_name}"
    echo "Connected to AKS cluster: ${aks_cluster_name}"
    kubectl cluster-info
}

function pod-shell() {
    if [ -z "$1" ]; then
        echo "Usage: pod-shell <pod-name> [namespace]"
        return 1
    fi
    local namespace=""
    if [ -n "$2" ]; then
        namespace="-n $2"
    fi
    kubectl exec -it $namespace "$1" -- /bin/bash
}

function watch-pods() {
    local namespace=""
    if [ -n "$1" ]; then
        namespace="-n $1"
    fi
    watch kubectl get pods $namespace
}

# Auto-completion
source <(kubectl completion bash)
source <(helm completion bash)
complete -F __start_kubectl k

EOF

# Set ownership
chown azureuser:azureuser /home/azureuser/.bashrc

# Create a welcome message
cat << 'EOF' > /etc/motd

╔══════════════════════════════════════════════════════════════╗
║                    AKS Private Cluster Jumpbox              ║
║                                                              ║
║  This jumpbox provides access to your private AKS cluster   ║
║                                                              ║
║  Available tools:                                            ║
║  • Azure CLI (az)                                            ║
║  • kubectl (k)                                               ║
║  • Helm                                                      ║
║  • k9s                                                       ║
║  • kubectx/kubens                                            ║
║  • Docker                                                    ║
║  • Terraform                                                 ║
║                                                              ║
║  Quick start:                                                ║
║  1. az login --use-device-code                              ║
║  2. aks-connect                                              ║
║  3. kubectl get nodes                                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

# Enable and start services
systemctl enable docker
systemctl start docker

# Create log directory for troubleshooting
mkdir -p /var/log/jumpbox-init
echo "Jumpbox initialization completed at $(date)" > /var/log/jumpbox-init/init.log

echo "Jumpbox initialization script completed successfully!"