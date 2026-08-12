# Changelog

All notable changes to this project are documented here.

## 2026.08.0 - 2026-08-12

### Bug Fixes

- Broken 1Password MCP path and non-fatal auto-merge

### Miscellaneous

- Auto-merge Dependabot PRs into dev via required status check (#24) (#24)
- Bump redhat-actions/push-to-registry from 2.8 to 3.0.0 (#26) (#26)
- Remove bespoke dependabot-automerge workflow (#28) (#28)
- Skip the image build when no image inputs change (#29) (#29)
- Require CodeRabbit review before merging dependency PRs (#30) (#30)
- Auto-queue dependency PRs instead of requiring the checkbox (#31) (#31)
- Upgrade configuration to current format (#32) (#32)
- Bump actions/checkout from 7.0.0 to 7.0.1 (#18) (#18)
- Bump aws-actions/configure-aws-credentials (#21) (#21)
- Bump redhat-actions/buildah-build from 2.13 to 3.0.2 (#25) (#25)

### Other

- Merge pull request #23 from dangreco/fix/actions-1password-automerge (#23)
- Update merge queue configuration (#27) (#27)
- Update merge protections (#33) (#33)
- Update merge protections (#34) (#34)

## 2026.07.11 - 2026-07-12

### Miscellaneous

- Remove ulauncher

### Other

- Add Wine and runtime essentials
- Fix Wine install: use wine meta-package deps, correct gecko name
- Merge pull request #16 from dangreco/feat/wine (#16)
- Merge pull request #15 from dangreco/release/next (#15)

## 2026.07.10 - 2026-07-10

### Features

- Add ulauncher
- Add nmap

### Miscellaneous

- Improve branching strategy

### Other

- Merge pull request #14 from dangreco/release/next (#14)

## 2026.07.9 - 2026-07-07

### Bug Fixes

- Regenerate initramfs

### Other

- Merge pull request #10 from dangreco/release/next (#10)

## 2026.07.8 - 2026-07-07

### Bug Fixes

- Transient root

### Other

- Merge pull request #9 from dangreco/release/next (#9)

## 2026.07.7 - 2026-07-07

### Bug Fixes

- Use proper cosign args

### Other

- Merge pull request #8 from dangreco/release/next (#8)

## 2026.07.6 - 2026-07-07

### Bug Fixes

- Use proper cosign

### Other

- Merge pull request #7 from dangreco/release/next (#7)

## 2026.07.5 - 2026-07-06

### Bug Fixes

- Use old signing bundle

### Other

- Merge pull request #6 from dangreco/release/next (#6)

## 2026.07.4 - 2026-07-04

### Bug Fixes

- Make ISO interactive

### Miscellaneous

- Update README.md

### Other

- Merge pull request #5 from dangreco/release/next (#5)

## 2026.07.3 - 2026-07-04

### Features

- Add s3 publishing

### Other

- Merge pull request #4 from dangreco/release/next (#4)

## 2026.07.2 - 2026-07-04

### Bug Fixes

- Fix cosign step

### Other

- Merge pull request #3 from dangreco/release/next (#3)

## 2026.07.1 - 2026-07-04

### Features

- Add release iso

### Other

- Merge pull request #2 from dangreco/release/next (#2)

## 2026.07.0 - 2026-07-04

### Features

- Initial ublue Silverblue image scaffold

### Bug Fixes

- Pass GHCR credentials to cosign sign
- Bind-mount bib config to avoid named-volume error
- Fix build-disk action

### Miscellaneous

- Use lab/lab test image credentials
- Add release pipeline

### Other

- Add udev rules, packages, improve build scripts
- Merge pull request #1 from dangreco/release/next (#1)


