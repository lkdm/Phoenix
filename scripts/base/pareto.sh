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

# Polkit policy for Pareto helper (Atomic workaround)
# Adds 
mkdir -p /usr/share/polkit-1/actions
cat << 'EOF' > /usr/share/polkit-1/actions/com.paretosecurity.agent.policy
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">

<policyconfig>
  <action id="com.paretosecurity.agent.run-helper">
    <description>Run Pareto Security privileged helper</description>
    <message>Authentication is required to run Pareto Security system checks</message>
    <defaults>
      <allow_any>no</allow_any>
      <allow_inactive>no</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
    <exec>/usr/bin/paretosecurity helper</exec>
  </action>
</policyconfig>
EOF

# Cleanup repo (updates baked into image)
rm -f /etc/yum.repos.d/pareto.repo

# Restore systemctl if it was stubbed
if [ -e /usr/bin/systemctl.real ]; then
  rm -f /usr/bin/systemctl
  mv /usr/bin/systemctl.real /usr/bin/systemctl
fi

# Should show enabled:
# systemctl is-enabled paretosecurity.socket
#
# Should show listening:
# systemctl status paretosecurity.socket
systemctl enable paretosecurity.socket
