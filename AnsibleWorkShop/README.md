# Deploy k3s cluster by ansible
ref: 
https://github.com/PyratLabs/ansible-role-k3s/tree/main

## Requirements
The host you're running Ansible from requires the following Python dependencies:

- `python >= 3.6.0`
- `ansible >= 2.9.16 or ansible-base >= 2.10.4`

Install python related dependency 
```
pip3 install -r requirement.txt
```

Install related ansible collections and roles
```
ansible-galaxy install -r requirement.yml
```

todo:
Investage python venv to run ansible playbook
https://www.redhat.com/sysadmin/python-venv-ansible