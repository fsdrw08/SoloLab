## Run ansible command in ansible container (Ansible Runner)
ref: 
 - [Introduction to Ansible Runner](https://ansible-runner.readthedocs.io/en/stable/intro/)
 - [Using Runner as a container interface to Ansible](https://ansible-runner.readthedocs.io/en/stable/container/)
 - [ansible-runner/Dockerfile](https://github.com/ansible/ansible-runner/blob/devel/Dockerfile)
 - [demo](https://github.com/ansible/ansible-runner/tree/devel/demo)

## pull or build the ansible-ee-aio image first
ref [../builder/README.md](../builder/README.md)
```powershell
podman pull docker.io/fsdrw08/sololab-ansible-ee
podman tag docker.io/fsdrw08/sololab-ansible-ee localhost/ansible-ee-aio-new
```

## create a role
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project)
$roleName="ansible-podman-rootless-play"
podman run --rm -v ./:/runner `
    localhost/ansible-ee-aio-new bash -c "cd /runner/project/roles/ && ansible-galaxy init $roleName"

podman run --rm -v ./:/runner `
    localhost/ansible-ee-aio bash -c "ansible --version"
```


## deploy podman rootless
powershell:
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\runner\)

# deploy and config podman package
$private_data_dir = "/tmp/private"
$keyFile = "vagrant.key"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=Invoke-PodmanRootlessProvision.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

shell(put the key to ssh_key file first):
```shell
cd $(git rev-parse --show-toplevel)/AnsibleWorkShop/runner

# https://github.com/containers/podman/blob/main/troubleshooting.md#:~:text=In%20cases%20where%20the%20container%20image%20runs%20as%20a%20specific%2C%20non%2Droot%20user
private_data_dir="/tmp/private"
keyFile="admin.key"
podman run --rm --userns=keep-id \
    -e RUNNER_PLAYBOOK=Invoke-PodmanRootlessProvision.yml \
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False \
    -v ./:$private_data_dir \
    docker.io/fsdrw08/sololab-ansible-ee \
    bash -c  "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
# bash -c "ansible-runner run $private_data_dir -vv"
```

## run podman play 
```powershell

# deploy pod (run podman play)
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-PodmanRootlessPlay.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv
```

## deploy FreeIPA by invoke podman rootless play role
```powershell
# deploy FreeIPA in podman
$private_data_dir = "/tmp/private"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=Deploy-FreeIPAInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/vagrant.key > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"

# FreeIPA post-process
$private_data_dir = "/tmp/private"
podman run --rm --userns=keep-id `
    --dns 192.168.255.11 `
    -e RUNNER_PLAYBOOK=Update-FreeIPAConfig.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/vagrant.key > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```
Ref:
- [Kerberos kinit: Unknown credential cache type while getting default ccache](https://stackoverflow.com/questions/48836113/kerberos-kinit-unknown-credential-cache-type-while-getting-default-ccache)

After FreeIPA deployed, if need to run `ipa xxx xxx` related command in freeipa container, update `/etc/krb5.conf` first
```shell
sudo sed -ri "s/^ default_ccache_name = (.*)/# default_ccache_name = \1/g" /etc/krb5.conf
```

## deploy StepCA by invoke podman rootless play role
```powershell
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
$private_data_dir = "/tmp/private"
$keyFile = "vagrant.key"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=Deploy-StepCAInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

```shell
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
private_data_dir="/tmp/private"
keyFile="podmgr.key"
podman run --rm --userns=keep-id \
    -e RUNNER_PLAYBOOK=Deploy-StepCAInPodman.yml \
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False \
    -v ./:$private_data_dir \
    -v ../../KubeWorkShop/:/KubeWorkShop/ \
    docker.io/fsdrw08/sololab-ansible-ee \
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

## deploy Traefik by invoke podman rootless play role
```powershell
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
$private_data_dir = "/tmp/private"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=Deploy-TraefikInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/vagrant.key > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

shell(put the key to ssh_key file first):
```shell
cd $(git rev-parse --show-toplevel)/AnsibleWorkShop/runner

# https://github.com/containers/podman/blob/main/troubleshooting.md#:~:text=In%20cases%20where%20the%20container%20image%20runs%20as%20a%20specific%2C%20non%2Droot%20user
private_data_dir="/tmp/private"
keyFile="podmgr.key"
podman run --rm --userns=keep-id \
    -e RUNNER_PLAYBOOK=Deploy-TraefikInPodman.yml \
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False \
    -v ./:$private_data_dir \
    -v ../../KubeWorkShop/:/KubeWorkShop/ \
    docker.io/fsdrw08/sololab-ansible-ee \
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```


## deploy GitLab by invoke podman rootless play role
```powershell
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
$private_data_dir = "/tmp/private"
$keyFile="vagrant.key"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=Deploy-GitlabInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

```powershell
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
$private_data_dir = "/tmp/private"
# $keyFile="vagrant.key"
$keyFile="podmgr.key"
podman run --rm --userns=keep-id `
    --dns 100.100.2.138 `
    -e RUNNER_PLAYBOOK=Deploy-GitlabInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

```shell
cd $(git rev-parse --show-toplevel)/AnsibleWorkShop/runner

private_data_dir="/tmp/private"
keyFile="podmgr.key"
podman run --rm --userns=keep-id \
    -e RUNNER_PLAYBOOK=Deploy-GitlabInPodman.yml \
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False \
    -v ./:$private_data_dir \
    -v ../../KubeWorkShop/:/KubeWorkShop/ \
    docker.io/fsdrw08/sololab-ansible-ee \
    bash -c "mkdir -p ~/.ssh; 
    cat $private_data_dir/env/$keyFile > ~/.ssh/ssh.key; 
    chmod 600 ~/.ssh/ssh.key;
    ansible-runner run $private_data_dir -vv"
```

## deploy hashicorp vault in podman by invoke podman rootless play role
```powershell
podman run --rm `
    -e RUNNER_PLAYBOOK=Deploy-VaultInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv

# initialize hashicorp vault
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=Initialize-Vault.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv

# deploy keycloak in podman
podman run --rm `
    -e RUNNER_PLAYBOOK=Deploy-KeyCloakInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv

# update keycloak config
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=Update-KeyCloakConfig.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv

# deploy MinIO in podman
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=Deploy-MinIOInPodman.yml `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
   localhost/ansible-ee-aio ansible-runner run /runner -vv

```


## deploy k3s
ref: 
https://github.com/PyratLabs/ansible-role-k3s/tree/main

- Add xanmanning.k3s repo as a submodule
```powershell
cd (git rev-parse --show-toplevel)
git submodule add https://github.com/PyratLabs/ansible-role-k3s.git AnsibleWorkShop/project/roles/xanmanning.k3s
# List Remote Git Tags
# https://phoenixnap.com/kb/git-list-tags
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project\roles\xanmanning.k3s)
git ls-remote --tags origin
# fetch remote tags
git fetch --all --tags --prune
# switch to the version tag
git checkout tags/v3.3.1
# if you want to remove it
cd (git rev-parse --show-toplevel)
# https://devconnected.com/how-to-clear-git-cache/#:~:text=The%20easiest%20way%20to%20clear%20your%20Git%20cache,ignore%20all%20files%20ending%20in%20%E2%80%9C%20.conf%20%E2%80%9C
git rm --cached AnsibleWorkShop/project/roles/xanmanning.k3s
```

- Ensure the ansible runner ee meet below requirement:
    - `python >= 3.6.0`
    - `ansible >= 2.9.16 or ansible-base >= 2.10.4`

- Run ansible runner to deploy k3s with role
ansible runner will make the project dir as default dir
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\project)

podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-xanmanning.k3s.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# have a check of k3s cert
openssl s_client -connect 127.0.0.1:6443

openssl x509 -in /var/lib/rancher/k3s/server/tls/server-ca.crt -text -noout
```

## deploy k8s resource
```powershell
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio

podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-HelmInfo.yml     
    -v ./:/runner localhost/ansible-ee-aio
    
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/test.yml `
    -v ./:/runner localhost/ansible-ee-aio `
    ansible-runner run /runner -vvvv
```

## debugs
```powershell
# terraform
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml `
    -v ./:/runner `
    -v ../../TerraformWorkShop/:/TerraformWorkShop/ `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml `
    -v ./:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# test merge
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Debug-Vars.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# copy item
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Copy-Items.yml `
    -v ./:/runner `
    -v ../../TerraformWorkShop/:/TerraformWorkShop/ `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# test j2 template render and copy to target
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-Podman.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# test podman socket api
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Invoke-PodmanAPI.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# config podman in target host
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-KernelModules.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# get service
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-Service.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# new podman session
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/New-PodmanSession.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# new podman session
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/New-PodmanNetwork.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# get vyos version 
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-VyosInfo.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# Set vyos dhcp ddns
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Set-VyosDhcpDDNS.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# get freeipa root ca cert
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-IPACACert.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# invoke freeipa request
podman run --rm `
    --add-host ipa.finra.sololab:192.168.255.31 `
    -e ANSIBLE_DISPLAY_SKIPPED_HOSTS=False `
    -e RUNNER_PLAYBOOK=./debug/Invoke-IPARequest.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv

# new ldap object
podman run --rm --add-host ipa.finra.sololab:192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/New-LDAPObject.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Get-Facts.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv

# extra vars
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Debug-ExtraVars.yml `
    -v ./:/runner `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv

# traefik
podman run --rm --add-host ipa.finra.sololab:192.168.255.31 `
    -e RUNNER_PLAYBOOK=Deploy-TraefikInPodman.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv

# create pod
podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/New-PodmanPod.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv

# call keycloak
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/Invoke-KeycloakRequest.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vvv


# test template check mode
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/Debug-Template.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# get cert
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/Get-RootCACert.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# debug delegate
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/Debug-Delegate.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

# try ansible vault
# https://stackoverflow.com/questions/714915/using-the-passwd-command-from-within-a-shell-script/11787889#11787889
podman run --rm `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio bash -c 'echo -e "password\npassword" | ansible-vault encrypt /KubeWorkShop/FreeIPA/password.txt'

# debug vault ldap config
podman run --rm `
    --dns 192.168.255.31 `
    -e RUNNER_PLAYBOOK=./debug/Debug-VaultLDAPAuth.yml `
    -v ./:/runner `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio ansible-runner run /runner -vv

podman run --rm `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    localhost/ansible-ee-aio bash -c 'ansible version'


```


## install freeipa server
```powershell
podman run --rm `
    -e RUNNER_PLAYBOOK=Invoke-FreeIPA.yml `
    -v ./:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml `
    -v ./:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm `
    -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml `
    -v ./:/runner `
    localhost/ansible-ee-k8s ansible-runner run /runner -vvvv
```