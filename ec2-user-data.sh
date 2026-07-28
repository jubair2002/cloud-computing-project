#!/bin/bash
# Paste this into the EC2 launch wizard under
# "Advanced details" -> "User data" (Ubuntu 22.04/24.04 AMI).
# It runs once, automatically, on first boot — you never SSH in for setup.
set -euxo pipefail

apt-get update -y
apt-get install -y ca-certificates curl gnupg git

# --- Docker Engine + Compose plugin (official repo) ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker ubuntu

# --- Deploy key for GitHub Actions ---
# Generate a dedicated ed25519 keypair for this instance BEFORE launch:
#   ssh-keygen -t ed25519 -f github-actions-deploy -C "github-actions"
# Paste the PUBLIC key below, and put the PRIVATE key in the GitHub
# secret EC2_SSH_KEY. Never reuse your personal SSH key for this.
mkdir -p /home/ubuntu/.ssh
echo "REPLACE_WITH_YOUR_PUBLIC_KEY" >> /home/ubuntu/.ssh/authorized_keys
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# --- Clone the repo ---
# Use a fine-grained GitHub PAT (read-only, this repo only) if it's
# private: https://<PAT>@github.com/<you>/shophub.git
sudo -u ubuntu git clone https://github.com/<your-username>/shophub.git /home/ubuntu/shophub

# Placeholder — the deploy workflow overwrites this with real values
# from the PROD_ENV_FILE secret on the very first deploy.
touch /home/ubuntu/shophub/.env
chown ubuntu:ubuntu /home/ubuntu/shophub/.env

# --- Open ports (also do this via the instance's Security Group in the console) ---
# 8000 -> backend, 5173 -> frontend, 22 -> SSH (restrict source to GitHub's IP
# ranges or a fixed IP if you can; avoid 0.0.0.0/0 on 22 where possible)