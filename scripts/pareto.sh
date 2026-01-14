#!/usr/bin/env bash

set -euo pipefail

# Setup repo
cat << EOF > /etc/yum.repos.d/pareto.repo
[paretosecurity-stable]
name=paretosecurity-stable
baseurl=https://pkg.paretosecurity.com/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.paretosecurity.com/paretosecurity.gpg
EOF

sudo dnf install -y paretosecurity


# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/pareto.repo -f

# Clean up
sudo dnf clean all
