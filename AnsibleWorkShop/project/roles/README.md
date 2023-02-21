## To create a new role:
```shell
ROLE=XXX
ansible-galaxy init $ROLE
```
## To run the role
Prepare a playbook like this 
```yaml
---
- hosts: localhost
  roles:
  - XXX
```
Then run the playbook
```shell
ansible-playbook /path/to/the/palybook.yaml
```