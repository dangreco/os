#!/usr/bin/bash
set -ouex pipefail

# Docker CE from Docker's official repo, installed alongside the base image's
# Podman. Kept in its own script (mirrors 1password.sh).

cat >/etc/yum.repos.d/docker-ce.repo <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

dnf5 install -y \
	docker-ce docker-ce-cli containerd.io \
	docker-buildx-plugin docker-compose-plugin

# Start Docker on demand (socket activation); docker.service pulls containerd.
systemctl enable docker.socket

# Auto-add human users to the docker group (service shipped via system_files).
systemctl enable docker-group-add.service
