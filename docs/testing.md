## File Server Profile Test

Environment:

- OS:
- Machine:
- Date:

Checks:

- Setup Center launched successfully
- Samba installed successfully
- Shared folder created at `/srv/reforge/share`
- Samba config backup created
- Re-running profile does not duplicate the Reforge Samba block
- Windows access path printed
- Linux access path printed
- Existing share contents were not deleted

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
