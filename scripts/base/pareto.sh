#!/usr/bin/env bash
set -euo pipefail

# Prevent RPM %post from interacting with systemd during image build
export SYSTEMCTL_SKIP_REDIRECT=1

# Hard-disable systemctl just in case the RPM calls it directly
if [ ! -e /usr/bin/systemctl.real ]; then
  mv /usr/bin/systemctl /usr/bin/systemctl.real 2>/dev/null || true
  ln -s /usr/bin/true /usr/bin/systemctl
fi

# Setup repo
cat << EOF > /etc/yum.repos.d/pareto.repo
[paretosecurity-stable]
name=paretosecurity-stable
baseurl=https://pkg.paretosecurity.com/rpm
enabled=1
gpgcheck=1
gpgkey=https://pkg.paretosecurity.com/paretosecurity.gpg
EOF

dnf install -y paretosecurity

# Enable service on first boot via preset (bootc best practice)
mkdir -p /usr/lib/systemd/system-preset
cat << EOF > /usr/lib/systemd/system-preset/90-pareto.preset
enable paretosecurity.service
EOF

# Cleanup repo (updates baked into image)
rm -f /etc/yum.repos.d/pareto.repo

# Restore systemctl if it was stubbed
if [ -e /usr/bin/systemctl.real ]; then
  rm -f /usr/bin/systemctl
  mv /usr/bin/systemctl.real /usr/bin/systemctl
fi
