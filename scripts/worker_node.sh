#!/bin/bash
set -ex

echo "Creating containerd configuration file with list of necessary modules that need to be loaded with containerd"

# Swap off is required by Kubernetes
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
EOF

echo "Load containerd modules"

sudo modprobe overlay
sudo modprobe br_netfilter 

echo "Creates configuration file for kubernetes-cri file (changed to k8s.conf)"
# sysctl params required by setup, params persist across reboots

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
EOF

echo "Applying sysctl params"

sudo sysctl --system

echo "Verify that the br_netfilter, overlay modules are loaded by running the following commands:"

lsmod | grep br_netfilter
lsmod | grep overlay

echo "Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:"

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

cat /proc/sys/net/ipv4/ip_forward

wget https://github.com/containerd/containerd/releases/download/v2.1.3/containerd-2.1.3-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-2.1.3-linux-amd64.tar.gz 

wget -qO - https://raw.githubusercontent.com/containerd/containerd/main/containerd.service  | sudo tee /etc/systemd/system/containerd.service > /dev/null

sudo systemctl daemon-reload 
sudo systemctl start containerd.service 
sudo systemctl enable --now containerd.service 

echo "Create a default config file at default location"

sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "/ShimCgroup = ''/a \            SystemdCgroup = true" /etc/containerd/config.toml

echo "Restarting containerd"
sudo systemctl restart containerd

echo "Installing runc, the container runtime used by Containerd"
wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

echo "Install CNI Plugins for networking functionality"
wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz 

sudo apt-get update
sudo systemctl restart containerd

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

sudo systemctl status containerd

echo "Containerd Successfully installed, Now install Kubeadm, Kubelet and kubectl"

sudo apt-get update > /dev/null

# apt-transport-https may be a dummy package; if so, you can skip that package

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

echo "Installing latest versions"

sudo apt-get install -y kubelet kubeadm kubectl

echo "Fixate version to prevent upgrades"

sudo apt-mark hold kubelet kubeadm kubectl


sudo kubeadm join 174.129.13.189:6443 --token 3xxseg.enriglmtik60m5gh \
        --discovery-token-ca-cert-hash sha256:3a4da166935097a2667a27bd7e3a2c48e59fd9ad10dce40b815d4bb67b270f28 

sudo systemctl restart kubelet.service