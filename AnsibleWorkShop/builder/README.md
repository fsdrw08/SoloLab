## To build a ansible execution environment (Ansible EE, aka a container)
0. Pre-request
   - Install RedHat.podman
    ```
    winget install RedHat.podman
    ```

1. Install ansible-builder
   - Create and active python venv
    ```powershell
    python -m venv venv
    . .\venv\Scripts\activate
    ```
   - Install ansible-builder from pip
     - ref: [Chapter 2. Using Ansible Builder](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.0-ea/html-single/ansible_builder_guide/index)

    ```
    pip install ansible-builder --upgrade
    ```

2. Prepare container build file (Containerfile, aka dockerfile)
   - Generate Containerfile and podman related context with [definition.yml](definition.yml)
   ```powershell
   . .\venv\Scripts\activate
   ansible-builder create -f .\definition-with_semi_proxy.yml 
   ```
   - Fix some syntax (POIXFX) error in the Containerfile
   - Update the Containerfile, e.g.

3. Build the ansible runner image
```powershell
# with_proxy
podman build .\context\ --build-arg PROXY="http://192.168.1.189:7890" --tag ansible-ee-aio
podman build .\context\ --build-arg PROXY="http://192.168.255.102:7890" --tag ansible-ee-aio
# without_proxy
podman build .\context\ --tag ansible-ee-aio
```

## Run the ansible container (Ansible Runner)
ref: 
 - [Using Runner as a container interface to Ansible](https://ansible-runner.readthedocs.io/en/stable/container/)
 - [ansible-runner/Dockerfile](https://github.com/ansible/ansible-runner/blob/devel/Dockerfile)
 - [demo](https://github.com/ansible/ansible-runner/tree/devel/demo)

```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\builder)
# deploy k3s
podman run --rm -e RUNNER_PLAYBOOK=Invoke-xanmanning.k3s.yml -v ../:/runner localhost/ansible-ee-aio ansible-runner run /runner -vv

# have a check of k3s cert
openssl s_client -connect 127.0.0.1:6443

openssl x509 -in /var/lib/rancher/k3s/server/tls/server-ca.crt -text -noout


# deploy k8s resources 
podman run --rm -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml -v ../:/runner localhost/ansible-ee-aio
podman run --rm -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml -v ../:/runner localhost/ansible-ee-aio ansible-runner run /runner -vvvv

podman run --rm -e RUNNER_PLAYBOOK=./debug/Get-HelmInfo.yml -v ../:/runner localhost/ansible-ee-aio
podman run --rm -e RUNNER_PLAYBOOK=./debug/test.yml -v ../:/runner localhost/ansible-ee-aio ansible-runner run /runner -vvvv

# debug terraform
podman run --rm -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml -v ../:/runner -v ../../TerraformWorkShop/:/TerraformWorkShop/ localhost/ansible-ee-k8s ansible-runner run /runner -vvvv
podman run --rm -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# copy items
podman run --rm -e RUNNER_PLAYBOOK=./debug/Copy-Items.yml -v ../:/runner -v ../../TerraformWorkShop/:/TerraformWorkShop/ localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# install freeipa server
podman run --rm -e RUNNER_PLAYBOOK=./Invoke-FreeIPA.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# config podman in target host
podman run --rm -e RUNNER_PLAYBOOK=./debug/Initialize-Podman.yml -v ../:/runner localhost/ansible-ee-aio ansible-runner run /runner -vv

# test j2 template render and copy to target
podman run --rm -e RUNNER_PLAYBOOK=./debug/Invoke-Podman.yml -v ../:/runner -v ../../KubeWorkShop/:/KubeWorkShop/ localhost/ansible-ee-aio ansible-runner run /runner -vv

# create a role
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\builder)
podman run --rm -v ../:/runner localhost/ansible-ee-aio bash -c "cd /runner/roles/ && ansible-galaxy init ansible-podman-rootless"

podman run --rm -v ../:/runner localhost/ansible-ee-aio bash -c "cd /runner/roles/ && ansible --version"
```