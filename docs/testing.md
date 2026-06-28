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
- Windows access worked: Passed
- Mapped share as Z: drive: Passed
- File creation from Windows worked: Passed
- Re-running profile did not duplicate Samba config: Passed

Windows access path:
\\192.168.0.6\ReforgeShare

Windows mapped drive:
Z:

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
- Dashboard URL opened from Windows: Passed
- DNS IP printed: Passed
- Router/device DNS instructions shown: Passed
- No router settings changed automatically: Passed
- Gravity/blocklist update completed: Passed
- Domains on blocklist loaded: Passed
- nslookup using Pi-hole DNS worked: Passed
- Blocking test with doubleclick.net returned 0.0.0.0 / ::: Passed
- Re-running profile detects existing Pi-hole:

Pi-hole dashboard:
http://192.168.0.6/admin

DNS test:
nslookup google.com 192.168.0.6

Blocking test:
nslookup doubleclick.net 192.168.0.6

## Media Server Profile Test

Environment:
- OS: MX Linux 25.2 XFCE x64
- Machine: VirtualBox VM
- Host OS: Windows
- Date: 2026-06-28

Checks:
- Setup Center launched successfully: Passed
- Jellyfin installer completed successfully: Passed
- Media folders created: Passed
- Jellyfin service started: Passed
- Jellyfin listening on port 8096: Passed
- Dashboard URL opened from Windows: Passed
- First-time setup wizard appeared: Passed
- Movies library visible: Passed
- Shows library visible: Passed
- Re-running profile detects existing Jellyfin:

Jellyfin URL:
http://192.168.0.6:8096