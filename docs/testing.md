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

- OS:
- Machine:
- Date:

Checks:

- Setup Center launched successfully
- Jellyfin installer completed successfully
- Media folders created
- Jellyfin service started
- Dashboard URL opened from another device
- First-time setup wizard appeared
- Media library path was added successfully
- Re-running profile detects existing Jellyfin
