# Reforge Linux ISO Customization Checklist

## Pre-Snapshot Requirements

- [ ] MX Linux 25.2 XFCE x64 installed in VM
- [ ] Reforge Linux repo cloned
- [ ] Latest main branch pulled
- [ ] All scripts syntax checked
- [ ] All 3 profiles tested
- [ ] Reforge system installer run successfully
- [ ] `reforge-setup` command works
- [ ] Desktop/application launcher works

## ISO Readiness Verification

- [ ] `/opt/reforge-linux` exists
- [ ] `/usr/local/bin/reforge-setup` exists and is executable
- [ ] `/usr/share/applications/reforge-setup.desktop` exists
- [ ] Reforge Setup Center opens from the application menu
- [ ] Reforge Setup Center opens from the terminal with `reforge-setup`

## Commands to Run Before Snapshot

```bash
cd ~/Desktop/Reforge-Linux
git pull
find scripts profiles -name "*.sh" -exec chmod +x {} \;
for file in scripts/*.sh profiles/*/install.sh; do bash -n "$file"; done
sudo bash scripts/install-reforge-system.sh
reforge-setup
```

## Branding Checklist

- [ ] Add Reforge wallpaper
- [ ] Set default wallpaper
- [ ] Add logo/icon later
- [ ] Confirm desktop launcher exists
- [ ] Confirm app menu entry exists

## Cleanup Checklist

- [ ] Clear browser history if needed
- [ ] Remove temporary downloads
- [ ] Clean apt cache
- [ ] Remove old logs if appropriate
- [ ] Do not delete Reforge files
- [ ] Do not delete useful test screenshots

## MX Snapshot Steps

1. Open MX Snapshot.
2. Choose a snapshot type suitable for a redistributable ISO.
3. Include current system configuration.
4. Exclude personal/private data where possible.
5. Generate the ISO.
6. Save the ISO outside the repository.
7. Do not commit the ISO to Git.

## Post-Snapshot Testing

- [ ] Boot generated ISO in new VM
- [ ] Confirm desktop loads
- [ ] Confirm Reforge Setup Center launcher works
- [ ] Confirm `reforge-setup` command works
- [ ] Test System Info
- [ ] Test at least one profile
- [ ] Later test on Dell Inspiron 1464

## Release Artifact Checklist

- [ ] ISO file
- [ ] SHA256 checksum
- [ ] Release notes
- [ ] Screenshots
- [ ] Known limitations

## Safety Notes

- This is an experimental portfolio build
- Not production-ready
- Users should review scripts before running
- Pi-hole requires static IP/DHCP reservation for real use
