# os

Atomic Fedora Silverblue, personalized. A custom [Universal Blue](https://universal-blue.org)
`silverblue-main` image with my packages, services, and config baked in — built, signed, and
shipped as an OCI image plus an installable ISO.

[![build](https://img.shields.io/github/actions/workflow/status/dangreco/os/build.yml?branch=main&style=flat-square)](https://github.com/dangreco/os/actions/workflows/build.yml)
[![release](https://img.shields.io/github/v/release/dangreco/os?style=flat-square)](https://github.com/dangreco/os/releases/latest)
[![license](https://img.shields.io/github/license/dangreco/os?style=flat-square)](./LICENSE)
[![base](https://img.shields.io/badge/base-Fedora%2044-51A2DA?style=flat-square&logo=fedora&logoColor=white)](https://universal-blue.org)

## Install

First-time rebase from stock Silverblue (unverified bootstrap):

```sh
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/dangreco/os:latest
sudo systemctl reboot
```

After configuring the signature policy with `cosign.pub`, switch to the verified image:

```sh
sudo bootc switch ghcr.io/dangreco/os:latest
```

Prefer a clean install? Grab the latest ISO from the [releases page](https://github.com/dangreco/os/releases/latest) — see [Releases](#releases).

## Build

Requires [`task`](https://taskfile.dev) and `podman`. Run `task --list` for the full set.

```sh
task build          # build the OCI image locally
task build:iso      # build an interactive installer ISO
task vm:iso         # boot the installer ISO in a VM (http://localhost:8006)
```

## Customize

Edit `build_files/build.sh` (packages via `dnf5`, services via `systemctl`) and drop config
under `system_files/` (copied to the image root). Pin the Fedora release via the `FROM` tag in
`Containerfile`.

## Releases

Each release hosts an installable ISO (`os-<version>.iso`) on S3 — direct download links live
in the [release notes](https://github.com/dangreco/os/releases/latest), alongside a `.sha256`
checksum and a cosign `.bundle`. Only the current production version is retained.

Verify a download:

```sh
sha256sum -c os-<version>.iso.sha256
cosign verify-blob --bundle os-<version>.iso.bundle --key cosign.pub os-<version>.iso
```

## License

GPL-3.0-or-later.
