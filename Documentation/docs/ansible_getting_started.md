# Getting started
programs that should be installed:
- [Ansible](https://www.ansible.com/)
- [git](https://git-scm.com/)



Clone the sprawl repo:
```bash
git clone git@github.com:ringbuffer-org/SPRAWL.git
```


## hosts/inventory
hosts file contains all hosts that can be accessed by playbooks.

``` ini
[active_sprawl_nodes]
AP-03 ansible_user=member 
AP-04 ansible_user=member 
AP-05 ansible_user=member
AP-07 ansible_user=member
AP-08 ansible_user=member
AP-09 ansible_user=member
AP-10 ansible_user=member
AP-14 ansible_user=member
AP-15 ansible_user=member
AP-16 ansible_user=member

[sprawl_nodes]
AP-01.local ansible_user=member
AP-0[3:9].local ansible_user=member
AP-1[0:7].local ansible_user=member
```


## ansible.cfg
is most easily found by ansible when it is in the same directory from which ansible commands are executed.
config file that informs ansible about some default settings.

``` ini
[defaults]
inventory = /path/to/hosts/file
# inventory = hosts
private_key_file=/path/to/private/key
host_key_checking=false
```
## ssh keys
asymetrical encryption keys, used for authentication

Transfer own key to hosts:
```bash
ansible-playbook pi_setup/playbooks/install_ssh_key.yml --ask-pass -e "key=path/to/public/key.pub" --fork=14
```

## Start Ansible Piece

``` bash
ansible-playbook Delay_Graph/launch_delay_ring.yml --fork 14 
```