# Reforge Linux ISO Build Plan

**Old hardware. New purpose.**

## Overview

Reforge Linux starts as a Debian/MX-based remix focused on old-PC repurposing. The goal is to create a custom installable ISO that includes Reforge Linux branding and the Reforge Setup Center, so users can install a lightweight system and choose a practical role for an unused computer.

The first ISO path is intentionally simple: start from MX Linux 25.2 XFCE x64, customize it in a VM, and use MX Snapshot to generate a testable ISO.

## Why MX Linux?

MX Linux is a good base for the early Reforge Linux ISO work because it is:

- Debian-based
- Lightweight with the XFCE desktop
- Suitable for older PCs
- Equipped with good Live USB tools
- Friendly to remastering through MX Snapshot

MX Snapshot and MX remastering tools make custom ISO generation easier for the v0.1/v1.0 stage. Debian Live-Build may be explored later for a more advanced and reproducible build pipeline.

## High-Level ISO Build Flow

1. Install MX Linux 25.2 XFCE x64 in a VM
2. Clone the Reforge Linux repository
3. Verify scripts and profiles
4. Add Reforge Setup Center launcher
5. Add branding/wallpaper
6. Clean unnecessary temporary files
7. Use MX Snapshot to generate ISO
8. Test generated ISO in VirtualBox
9. Test generated ISO on old Dell hardware
10. Attach ISO to GitHub Releases with checksum and release notes

## Repository vs ISO Strategy

The GitHub repository contains source code, scripts, configs, documentation, and build notes. ISO files should not be committed directly to Git because they are large binary release artifacts.

Instead, ISO files should be uploaded to GitHub Releases. Each ISO release should include:

- Checksum
- Release notes
- Tested environment notes
- Known limitations

## Planned ISO Contents

- Reforge Setup Center
- File Server profile
- Ad-Blocking DNS Server profile
- Media Server profile
- README/docs
- Basic branding
- Launcher shortcut
- Lightweight MX/XFCE base

## Setup Center Launcher

The script `scripts/install-reforge-launcher.sh` installs a desktop launcher and application menu entry for Reforge Setup Center on XFCE/MX Linux.

It creates `~/.local/share/applications/reforge-setup.desktop` and, when the user's Desktop folder exists, `~/Desktop/reforge-setup.desktop`.

## Things Not Included Yet

- No custom package repository yet
- No long-term security maintenance promise yet
- No Debian Live-Build pipeline yet
- No Calamares customization yet
- Not intended as a production server OS yet

## v0.4 ISO TODO Checklist

- [ ] Create launcher for setup center
- [ ] Add Reforge wallpaper
- [ ] Add desktop shortcut
- [ ] Add terminal command alias if useful
- [ ] Clean package cache
- [ ] Run syntax checks
- [ ] Test all profiles in VM
- [ ] Generate MX Snapshot ISO
- [ ] Boot generated ISO in VM
- [ ] Test on Dell Inspiron 1464
- [ ] Create checksum
- [ ] Draft release notes

## Future Advanced Build Path

Future versions may move beyond manual MX Snapshot builds toward a more reproducible and polished build process. Possible improvements include:

- Debian Live-Build
- Automated ISO pipeline
- Custom package/deb for Reforge Setup Center
- GUI setup center
- Better installer branding
