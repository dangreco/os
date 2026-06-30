#!/usr/bin/bash
set -ouex pipefail

# Copy any tracked /etc and /usr overrides into the image.
if [ -d /system_files ]; then
	cp -rT /system_files /
fi

# --- Remove packages (TODO) ----------------------------------------------------
# dnf5 remove -y firefox
# Base-protected packages instead need: rpm-ostree override remove <pkg>

# --- Install packages (TODO) ---------------------------------------------------
# dnf5 install -y <pkg>
# COPR example:
#   dnf5 -y copr enable <owner>/<repo>
#   dnf5 -y install <pkg>
#   dnf5 -y copr disable <owner>/<repo>

# --- Toggle services (TODO) ----------------------------------------------------
# systemctl enable  <unit>.service
# systemctl disable <unit>.service
