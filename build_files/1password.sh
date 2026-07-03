#!/usr/bin/bash
set -ouex pipefail

# Install 1Password (desktop + CLI) on a bootc/ostree image.
#
# On libostree systems /opt is a symlink to var/opt, and /var/opt does not even
# exist at build time -- so the RPM's cpio payload fails to create /opt/1Password.
# /var is also a mutable, stateful FS overlaid at runtime and is NOT committed
# into the image, so anything installed under it would vanish. We therefore
# install, relocate /opt/1Password into immutable /usr/lib/1Password, and
# recreate the /opt/1Password path at runtime via tmpfiles.d.

# Pinned GIDs for the groups 1Password's helpers run as. These must be >1000 and
# must not collide with real groups -- the human-user GID range on Fedora starts
# at 1000, so we deliberately skip well past it. 1500/1600 match the GIDs
# ublue-os/bling reserves; 1700 continues the pattern for the newer MCP group.
GID_ONEPASSWORD=1500
GID_ONEPASSWORDCLI=1600
GID_ONEPASSWORDMCP=1700

# Create /var/opt so the RPM's cpio payload can extract /opt/1Password.
mkdir -p /var/opt

# Repo + signing key.
rpm --import https://downloads.1password.com/linux/keys/1password.asc
cat >/etc/yum.repos.d/1password.repo <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey="https://downloads.1password.com/linux/keys/1password.asc"
EOF

dnf5 install -y 1password 1password-cli
rm -f /etc/yum.repos.d/1password.repo # updates ship in new images

# Relocate out of ephemeral /var into immutable /usr, clean up the staging dir.
mv /var/opt/1Password /usr/lib/1Password
rmdir /var/opt 2>/dev/null || true

# Point the launcher at the runtime /opt path (recreated below via tmpfiles).
rm -f /usr/bin/1password
ln -s /opt/1Password/1password /usr/bin/1password

# The RPM's %post bakes the onepassword/onepassword-cli/onepassword-mcp groups
# straight into /etc/group with dynamically allocated GIDs (1000-1002) that
# collide with the human-user GID range. Strip them so our sysusers.d entries
# below own the groups at stable, reserved GIDs.
sed -i '/^onepassword/d' /etc/group /etc/gshadow

# --- after-install.sh equivalents (compare /usr/lib/1Password/after-install.sh) ---
# chrome-sandbox needs setuid (electron/electron#17972).
chmod 4755 /usr/lib/1Password/chrome-sandbox

# BrowserSupport helper: setgid to the onepassword group (browser <-> app link).
chgrp "${GID_ONEPASSWORD}" /usr/lib/1Password/1Password-BrowserSupport
chmod g+s /usr/lib/1Password/1Password-BrowserSupport

# op CLI: setgid to the onepassword-cli group (CLI <-> app link).
chgrp "${GID_ONEPASSWORDCLI}" /usr/bin/op
chmod g+s /usr/bin/op

# MCP server helper: setgid to the onepassword-mcp group (app verifies callers).
chgrp "${GID_ONEPASSWORDMCP}" /usr/lib/1Password/onepassword-mcp
chmod g+s /usr/lib/1Password/onepassword-mcp

# Desktop entry + icons into /usr/share.
install -Dm0644 /usr/lib/1Password/resources/1password.desktop \
	/usr/share/applications/1password.desktop
cp -rf /usr/lib/1Password/resources/icons/* /usr/share/icons/ 2>/dev/null || true

# Declare the groups with pinned GIDs (build-time groups don't persist).
printf 'g onepassword %s\n' "${GID_ONEPASSWORD}" >/usr/lib/sysusers.d/onepassword.conf
printf 'g onepassword-cli %s\n' "${GID_ONEPASSWORDCLI}" >/usr/lib/sysusers.d/onepassword-cli.conf
printf 'g onepassword-mcp %s\n' "${GID_ONEPASSWORDMCP}" >/usr/lib/sysusers.d/onepassword-mcp.conf
# Drop the rpm-ostree-generated group entries (they don't pin our GIDs).
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword.conf \
	/usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword-cli.conf \
	/usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword-mcp.conf

# Recreate /opt/1Password at runtime via tmpfiles (since /var/opt is empty at boot).
printf 'L  /opt/1Password  -  -  -  -  /usr/lib/1Password\n' \
	>/usr/lib/tmpfiles.d/onepassword.conf
