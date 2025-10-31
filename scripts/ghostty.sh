#!/usr/bin/env bash

set -euo pipefail

sudo dnf copr enable -y scottames/ghostty
sudo dnf install -y ghostty

# Clean up
if [ -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo ]; then
    sudo rm /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo
fi
sudo dnf clean all
