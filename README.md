# os

A custom, atomic Fedora Silverblue image — Universal Blue `silverblue-main` with
personal package and service customizations baked in.

## Build

```sh
task build           # build the OCI image locally
task build-qcow2     # build a qcow2 disk image
task build-iso       # build an installable ISO
task run-vm-qcow2    # boot it in a VM (http://localhost:8006)
```

## Customize

Edit `build_files/build.sh` (packages via `dnf5`, services via `systemctl`) and drop
config under `system_files/` (copied to the image root). Pin the Fedora release via the
`FROM` tag in `Containerfile`.

## Install

First-time rebase from stock Silverblue (unverified bootstrap):

```sh
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/dangreco/os:latest
sudo systemctl reboot
```

Then move to the signed image (after installing `cosign.pub` into the container policy):

```sh
sudo bootc switch ghcr.io/dangreco/os:latest
```

## License

GPL-3.0-or-later.
