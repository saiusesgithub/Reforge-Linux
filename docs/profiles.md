## Ad-Blocking DNS Server

Purpose:
Turns an old PC into a network-wide ad-blocking DNS server using Pi-hole.

What it does:

- Installs Pi-hole
- Shows dashboard URL
- Shows DNS IP
- Gives router/device DNS setup instructions

Important notes:

- Static/reserved IP is recommended
- Router DNS settings are not changed automatically
- PC must stay powered on for DNS blocking to work

## Media Server

Purpose:
Turns an old PC into a home media streaming server using Jellyfin.

What it does:

- Installs Jellyfin
- Creates media folders under `/srv/reforge/media`
- Starts Jellyfin service
- Shows the local Jellyfin URL
- Gives first-time setup instructions

Important notes:

- Add movies, shows, music, and videos to the created media folders
- Open Jellyfin at `http://<PC-IP>:8096`
- Complete the Jellyfin first-time setup wizard
- PC must stay powered on for streaming to work
