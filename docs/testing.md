## File Server Profile Test

Environment:
- OS: MX Linux 25.2 XFCE x64
- Machine: VirtualBox VM
- Host OS: Windows
- Date: 2026-06-28

Checks:
- Setup Center launched successfully: Passed
- Samba installed successfully: Passed
- ReforgeShare created: Passed
- Windows accessed share using `\\192.168.0.6\ReforgeShare`: Passed
- Windows mapped share as Z: drive: Passed
- File creation from Windows worked: Passed
- Local smbclient login worked: Passed
- Re-running profile did not duplicate Samba config: Passed

Windows access path:
`\\192.168.0.6\ReforgeShare`

Windows mapped drive:
`Z:`

## Ad-Blocking DNS Server Profile Test

Environment:
- OS: MX Linux 25.2 XFCE x64
- Machine: VirtualBox VM
- Host OS: Windows
- Date: 2026-06-28

Checks:
- Setup Center launched successfully: Passed
- Pi-hole installer started successfully: Passed
- Static IP warning handled by selecting Continue: Passed
- Pi-hole installed successfully: Passed
- Dashboard opened at `http://192.168.0.6/admin`: Passed
- Dashboard URL opened from Windows: Passed
- Gravity update completed: Passed
- Domains on blocklist loaded: 83,809
- `nslookup google.com 192.168.0.6` worked: Passed
- `nslookup doubleclick.net 192.168.0.6` returned `0.0.0.0 / :::`: Passed
- No router settings changed automatically: Passed
- Re-running profile detects existing Pi-hole: Passed

Pi-hole dashboard:
`http://192.168.0.6/admin`

DNS test:
`nslookup google.com 192.168.0.6`

Blocking test:
`nslookup doubleclick.net 192.168.0.6`

## Media Server Profile Test

Environment:
- OS: MX Linux 25.2 XFCE x64
- Machine: VirtualBox VM
- Host OS: Windows
- Date: 2026-06-28 / 2026-06-29

Checks:
- Setup Center launched successfully: Passed
- Jellyfin installed successfully: Passed
- Jellyfin service started: Passed
- Jellyfin listened on 0.0.0.0:8096: Passed
- Windows browser opened `http://192.168.0.6:8096`: Passed
- First-time setup wizard appeared: Passed
- Movies and Shows libraries visible: Passed
- Media folders created under `/srv/reforge/media`: Passed
- Dashboard URL opened from Windows: Passed
- Re-running profile detects existing Jellyfin: Passed

Jellyfin URL:
`http://192.168.0.6:8096`

## Known Notes

- Pi-hole requires a stable IP or DHCP reservation for real use.
- VM IP may change after reboot.
- Pi-hole DNS will timeout if the VM is shut down.
- Real hardware testing on the old Dell is still pending.
