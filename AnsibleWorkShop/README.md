# To run the playbook, build the ansible runner execution environment (aka a container) first

# Deploy k3s cluster by ansible
ref: 
https://github.com/PyratLabs/ansible-role-k3s/tree/main

add xanmanning.k3s repo as a submodule
```powershell
git submodule add https://github.com/PyratLabs/ansible-role-k3s.git AnsibleWorkShop/roles/xanmanning.k3s
# List Remote Git Tags
# https://phoenixnap.com/kb/git-list-tags
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project\roles\xanmanning.k3s)
git ls-remote --tags origin
# fetch remote tags
git fetch --all --tags --prune
# switch to the version tag
git checkout tags/v3.3.0
# if you want to remove it
cd (git rev-parse --show-toplevel)
git rm --cached AnsibleWorkShop/project/roles/xanmanning.k3s
```
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