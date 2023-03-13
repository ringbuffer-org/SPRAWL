# SPRAWL Notes


## User & Hostname

- Every PI has the same user name?
    - member

- Every PI has an individual hostname?
    - AP_x

## Network

- Ethernet: switch with manual DHCP addresses.

- Wireless: each PI opens an individual WiFi.
    - SSH enabled
    - VNC/RDP enabled


## Installed Software

- jack
- aj-snapshot

- JackTrip

- SuperCollider
    - sclang
    - scsynth
    - sc3-plugins

- PD (vanilla)

- Python3
    - python-osc

## Roll out (new) Pieces

Stuff for pieces in one directory only:

    /home/member/pieces/piece_subdir

Tow options:

- Distribute code & binaries via ssh (ansible).
- Grab all code (& build binaries) via repositories (pull via ansible).


## Start and Stop Pieces

- System needs to be back in plain state after each piece.
    - provide 'kill' playbooks
