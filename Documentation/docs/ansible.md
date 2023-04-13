# Raspberry Pi setup

I've used the [Raspberry Pi Imager](https://www.raspberrypi.com/news/raspberry-pi-imager-imaging-utility/) utility to flash the Raspberry Pi SD cards. 

The tool allows you to set an initial wifi, user, password, and host name. I used `Raspberry Pi OS Lite (64-bit)` as a starting point. This is a minimal distribution, which allows us to install only the packages we need.

The following scheme for names, hostnames and passwords can be used for a consistent setup:

+ *Username:* nodeA
+ *Hostname:* nodeA
+ *Password:* knotenA 

> Note: Only use this password scheme if the nodes are not connected to a public network. However, after you copied the ssh key (next step) you can disable ssh login via password, [as described here](https://askubuntu.com/questions/346857/how-do-i-force-ssh-to-only-allow-users-with-a-key-to-log-in). You could do this temporarily, since the Pis require an internet connection during the ansible setup.

The letter *A* is then replaced for each node by incrementing the letter. After the image is flashed, we copy our public ssh key to each Raspberry Pi using `ssh-copy-id`:

```bash
ssh-copy-id nodeA@nodeA.local
```

After this, the setup process is automated using Ansible. The configuration files are in this repository's *ansible* subfolder. 


# Ansible
## Config

Currently, these are only used to save some time running commands. `ansible.cfg` only contains two options:

```
[defaults]
INVENTORY = inventory

[ssh_connection]
pipelining = True
```

The first line sets the default "inventory" file, which contains the username@host for all Raspberry Pis which should be setup using Ansible.

The second option `pipelining = True` enables pipelining via ssh:

> Pipelining, if supported by the connection plugin, reduces the number of network operations required to execute a module on the remote server, by executing many Ansible modules without actual file transfer. It can result in a very significant performance improvement when enabled. However this conflicts with privilege escalation (become). **For example, when using ‘sudo:’ operations you must first disable ‘requiretty’ in /etc/sudoers on all managed hosts, which is why it is disabled by default.** This setting will be disabled if ANSIBLE_KEEP_REMOTE_FILES is enabled.

Note that I don't remember explicitly disabling `requiretty` on the Pis, so it might be the default. However, if there are problems with privilege you can try disabling this option.

---
## General Setup

### Software Overview

The `setup.yml` file contains a general setup for the Pis, making sure that the hardware is set up correctly and everything is up to date. The following software is installed:


+ *lightdm, lxsession*: Lightweight display manager [lxde](http://www.lxde.org/)
+ *supercollider, sc3-plugins*  [supercollider](https://supercollider.github.io/)
+ *jackd2* Jack audio
+ *python3-pip, git* Requirements for [p2psc](https://github.com/bontric/p2psc)
+ *xinput* I'm not quite sure whether this is still necessary..

### LXDE

The following command enables automatic login (so no password is required) after boot:

``` bash
raspi-config nonint do_boot_behaviour B4
```

As you may notice, the screen rotation is wrong, so we need to configure LXDE to flip the screen. This requires a reboot (which is done automatically), after which the LXDE configuration files are created.

To rotate the screen, a script is run after every boot which executes some xrandr commands to rotate the screen *and touchscreen*

```bash
#!/bin/bash
DISPLAY=:0 xrandr -o inverted
DISPLAY=:0 xinput --set-prop "generic ft5x06 (79)" "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1
```

### Keyboard layout
Is set to German by default, since the keyboards at TU are all German.

### Jack Audio

The following is required to allow jack audio real-time scheduling, see [here](
https://jackaudio.org/faq/linux_rt_config.html):

```yml
- name: Add user to audio group and enable jack limits config
  hosts: p2psc
  tags: jack
  tasks:
  - shell: usermod -a -G audio {{ ansible_user_id }}
    become: true
  - copy: remote_src=True src=/etc/security/limits.d/audio.conf.disabled dest=/etc/security/limits.d/audio.conf
    become: true   
```

Additionally, a script is created that automatically starts jack audio in a terminal after boot:

```bash
/usr/bin/jackd -P75 -dalsa -dhw:1 -p512 -n3 -s -r44100 2>&1 &
```

### P2PSC

Clones the p2psc repository (`~/p2psc`) and creates a script to automatically run p2psc in a terminal window after boot. There is also a 10s delay, to wait for a DHCP lease if a server is present:

```sh
#!/bin/bash
echo "Waiting for DHCP/AutoIP init..."
sleep 10;
PYTHONPATH=~/p2psc/ python3 ~/p2psc/p2psc/main.py -v
```

> This is required since p2psc automatically detects the IP address. If p2psc is started immediately after boot, it will use an AUTO-IP address, which will lead to issues in a DHCP enabled network.


Additionally, the setup creates a p2psc configuration file with the "name" set to each host's host name:

```json
{
    "name": "{{ ansible_user_id }}",
    "zeroconf": true,
    "ip": null,
    "port": 3760
}
```


### Supercollider

Since we want to use the p2psc supercollider library, a config file for supercollider is created:

` ~/.config/SuperCollider/sclang_conf.yaml`
```yaml
includePaths:
    -    ~/p2psc/libs/sclang
excludePaths:
    []
postInlineWarnings: false
```
---
## Jacktrip Setup

> Note that this has not been tested for a while and was only a proof of concept. So take it with a grain of salt ;)

### jacktrip
When I created this script, the `jacktrip` provided in the Ubuntu repositories was missing some essential features, which is why I created an extra step to clone and compile a more recent version of jacktrip. This might not be necessary anymore!

### jack-matchmaker
Creates a systemd service that runs jack-matchmaker in the background. This allows us to automatically connect certain jack clients with others. Since we can update the configuration while this script is running, we can dynamically change the connections it makes. This allows us to map jack and jacktrip channels in a sensible manner.

### Supercollider
We also create a supercollider startup file, which sets the number of SC channels to 12 by default:

`~/.config/SuperCollider/startup.scd`
```yaml
s.options.numInputBusChannels = 12;
s.options.numOutputBusChannels = 12;
```

> Note: That the number of channels must match or exceed the number of nodes in the network + Output channels!

### Connection Setup
Note that this requires some manual intervention since the jack to jacktrip port mapping is not implemented dynamically. This is the current default mapping of nodes to supercollider ports:

```
nodeA:receive_1 
SuperCollider:in_3

SuperCollider:out_3
nodeA:send_1 

nodeB:receive_1 
SuperCollider:in_4

SuperCollider:out_4
nodeB:send_1 

nodeC:receive_1 
SuperCollider:in_5

SuperCollider:out_5
nodeC:send_1 

nodeD:receive_1 
SuperCollider:in_6

SuperCollider:out_6
nodeD:send_1 

nodeE:receive_1 
SuperCollider:in_7

SuperCollider:out_7
nodeE:send_1 

nodeF:receive_1 
SuperCollider:in_8

SuperCollider:out_8
nodeF:send_1 

nodeG:receive_1
SuperCollider:in_9

SuperCollider:out_9
nodeG:send_1 

nodeH:receive_1 
SuperCollider:in_10

SuperCollider:out_10
nodeH:send_1
```

The connection establishment is "semi-automatic" and uses the Ansible inventory to determine which connections need to be made. In a fixed setup, the script used here could be run after boot and automatically create all jackrip connections. 

Since this was more of a proof-of-concept, this is a bit hacky, but it worked if I remember correctly ;)
First, we create a list of other hosts for each node. This might a bit tricky to grasp, but we only want to create connections in *one* direction (which then are bidirectional). This means, not every node connects to every other node. This script creates a subset of nodes for each node to achieve this:

```
Example hosts [A,B,C,D]:

+ A connects to [B,C,D]
+ B connects to [C,D]
+ C connects to [D]
+ D connects to [] (none)
```

Which results in a fully connected graph

```bash
ownIndex={{ play_hosts.index(inventory_hostname) }}

index={{ index }}

echo "$ownIndex $index" >> /home/{{ ansible_user_id }}/test 

if [ "$ownIndex" -lt "$index" ]; then
    item={{ item }}
    remote_host_addr=${item#*@}
    remote_host=${remote_host_addr%%.*}
    echo -n "$remote_host " >> /home/{{ ansible_user_id }}/.jacktrip_connections ;
fi
```

This file is then used in a script to create a jacktrip hub instance and establish all connections:

```bash
#!/bin/bash

# start jacktrip server in hub (-S) mode for incoming connections
# and disable default connections (-D)
jacktrip -S -D > /dev/null 2>&1 & 

# wait 5 seconds to make sure all hubs are started
sleep 5; 

# Go through list of hosts and establish connections
hosts=$(cat /home/{{ ansible_user_id }}/.jacktrip_connections)
port=4464
for h in $hosts; do
    # create a 1-channel connection to each host (-n1)
    jacktrip -C ${h}.local -J $h -K {{ ansible_user_id }} -n1 -D -B${port} > /dev/null 2>&1 & 
    ((port=port+1))
done
```

---
## Running Ansible
*From within the ansible subfolder*, run the following command:

```bash
ansible-playbook setup.yml
```

> Note: Make sure that the `inventory` file in the ansible subfolder contains a line for each node you want to set up (e.g. nodeA@nodeA.local || \<user\>@\<hostname\>.local)



## Running Jacktrip

> Note that this is untested but *should* work!

Run the jacktrip connect script created during the jacktrip_setup:

```bash
 ansible p2psc -m shell -a "nohup ~/scripts/jt_connect.sh &"
```

Kill all jacktrip instances

```bash
 ansible p2psc -m shell -a "killall jacktrip&"
```
