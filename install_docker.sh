#!/bin/bash

set -e

echo "==> Removing old Docker versions..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

echo "==> Updating system..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo "==> Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo tee /etc/apt/keyrings/docker.asc > /dev/null
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "==> Adding Docker repository..."
ARCH=$(dpkg --print-architecture)
CODENAME=$(source /etc/os-release && echo "$VERSION_CODENAME")

echo \
"deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$CODENAME stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==> Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "==> Adding current user to docker group..."
sudo usermod -aG docker $USER || true

echo "==> Testing Docker..."
sudo docker run hello-world

echo "==> Done. Re-login or run 'newgrp docker' to use Docker without sudo."