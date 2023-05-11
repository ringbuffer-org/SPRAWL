# SPRAWL Notes

## User & Hostname

- Every PI has the same user name

  - member

- Every PI has an individual hostname
  - AP_XX

## Network

- Ethernet: switch with router and DHCP, nodes can be reached via hostnam.

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

# Initial Setup of Pi

Flash Rasperry Pi OS to a SD-Card, use these Settings in the RPi-Imager:

- set hostname: `AP-XX` (where `XX` is the associated number of the Pi)
- enable SSH, use password authentication
- set username and password
  - Username: `member`
  - Password:
- set locale settings (optional)

## Provisioning

After boot, execute these playbooks to make it run

```bash

ansible-playbook pi_setup/playbooks/install_ssh_key.yml --ask-pass -e "key=path/to/public/key"

ansible-playbook pi_setup/playbooks/full_setup.yml
```

# Jacktrip Configuration

Two options:

- One server on each PI, every PI has a client for each server (n Servers, n\*n-1 clients)
- p2p connections between all PIs ((n\*(n-1))/2 connections)

## Roll out (new) Pieces

Stuff for pieces in one directory only:

    /home/member/pieces/piece_subdir

Two options:

- Distribute code & binaries via ssh (ansible).
- Grab all code (& build binaries) via repositories (pull via ansible).

## Start and Stop Pieces

- System needs to be back in plain state after each piece.
  - provide 'kill' playbooks
