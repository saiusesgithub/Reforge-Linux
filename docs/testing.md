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

- OS:
- Machine:
- Date:

Checks:

- Setup Center launched successfully
- Pi-hole installer started successfully
- Pi-hole installed successfully
- Dashboard URL opened
- DNS IP printed
- Router/device DNS instructions shown
- No router settings changed automatically
- Re-running profile detects existing Pi-hole

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