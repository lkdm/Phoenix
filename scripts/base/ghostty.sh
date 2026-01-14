#!/usr/bin/env bash

set -euo pipefail

dnf copr enable -y scottames/ghostty
dnf install -y ghostty

# Clean up
if [ -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo ]; then
    rm /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:scottames:ghostty.repo
fi
