#!/usr/bin/bash
set -ouex pipefail

# Copy any tracked /etc and /usr overrides into the image. system_files lives
# alongside this script in the build context (bind-mounted at /ctx), so resolve
# it relative to $0 rather than assuming an absolute path.
system_files="$(dirname "$0")/system_files"
if [ -d "$system_files" ]; then
	cp -rT "$system_files" /
fi

# Install 1Password (desktop + CLI) with the ostree /opt relocation dance.
"$(dirname "$0")/1password.sh"

# Install Docker CE alongside the base image's Podman.
"$(dirname "$0")/docker.sh"

# --- Remove packages (TODO) ----------------------------------------------------
# dnf5 remove -y firefox
# Base-protected packages instead need: rpm-ostree override remove <pkg>

# --- Install packages ----------------------------------------------------------
# System-level utilities only; user CLI tooling lives in ../dotfiles (home-manager).
dnf5 install -y \
	lm_sensors \
	7zip unrar unar \
	strace ltrace sysstat powertop nethogs iperf3 pv \
	gdisk parted \
	dfu-util stlink openocd esptool \
	virt-manager libvirt qemu-kvm \
	podman-compose \
	android-tools \
	fish \
	nmap

# COPR example:
#   dnf5 -y copr enable <owner>/<repo>
#   dnf5 -y install <pkg>
#   dnf5 -y copr disable <owner>/<repo>

# --- Multimedia codecs ---------------------------------------------------------
# Full ffmpeg/libavcodec (H.264/HEVC/VP9/AV1/AAC) and the VA-API drivers
# (libva-intel-media-driver for Intel, mesa-dri-drivers for AMD) already come
# from the ublue-main base, so RPM Firefox has HW+SW decode out of the box.
# These fill the remaining gaps:
#   - mozilla-openh264: baked-in Cisco openh264 for WebRTC H.264 (otherwise
#     Firefox downloads it at runtime).
#   - gstreamer1-plugins-ugly: non-free codecs for GNOME media apps (Videos,
#     thumbnailers) -- not used by Firefox, but completes system-wide playback.
dnf5 install -y mozilla-openh264 gstreamer1-plugins-ugly

# --- Shell ---------------------------------------------------------------------
# Make fish the default login shell for new users; home-manager (../dotfiles)
# supplies the fish configuration. The default SHELL in /etc/default/useradd is
# honored by gnome-initial-setup (it doesn't pass -s), unlike supplementary
# groups. Ensure fish is a valid login shell first.
grep -qxF /usr/bin/fish /etc/shells || echo /usr/bin/fish >>/etc/shells
useradd -D -s /usr/bin/fish

# --- Virtualization ------------------------------------------------------------
# Start libvirt on demand (socket activation). Admin access is granted via the
# polkit rule in system_files (see 50-libvirt-wheel.rules).
systemctl enable libvirtd.socket

# --- Toggle services (TODO) ----------------------------------------------------
# systemctl enable  <unit>.service
# systemctl disable <unit>.service

# --- Initramfs -----------------------------------------------------------------
# Regenerate the initramfs so /etc/ostree/prepare-root.conf (composefs + transient
# root, from system_files) is embedded. ostree-prepare-root runs inside the
# initramfs and reads that config from there -- not from the deployed /etc -- so
# dropping the file in above has no effect at boot until the initramfs is rebuilt.
# Must run after the system_files copy so the current config is picked up.
KERNEL_VERSION="$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | tail -n1)"
dracut --force --no-hostonly --reproducible --zstd -v \
	--add ostree \
	"/usr/lib/modules/${KERNEL_VERSION}/initramfs.img" \
	"${KERNEL_VERSION}"
