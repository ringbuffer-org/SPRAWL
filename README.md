# SPRAWL

A repository for a fresh start with the system

Documentation: https://ringbuffer-org.github.io/SPRAWL/

# Usage
All ansible playbooks should be executed from the root of this repo, so the `ansible.cfg` and `hosts` files are correctly recognized.

The `ansible.cfg` should be edited to point to the correct private key used for authentication with the hosts.
The public key can be distributed using
```bash
ansible-playbook pi_setup/initial/install_ssh_key.yml --ask-pass -e "key=path/to/public/key.pub" --fork=14
```

The playbooks are organzied in different directories:
- **pi_setup** contains playbooks that are used to setup the pis for use with the system
    - **initial** contains playbooks used for the initial setup
    - **playbooks** contains playbooks that might be useful after setup
- **pieces** contains playbooks and files for starting the actual piecs