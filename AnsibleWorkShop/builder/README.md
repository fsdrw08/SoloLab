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
   cd .\with_proxy
   # or cd .\without_proxy
   ansible-builder create -f .\definition.yml 
   ```
   - Fix some syntax (POIXFX) error in the Containerfile
   - Update the Containerfile, e.g.

3. Build the ansible runner image
```
podman build .\context\ --build-arg PROXY="http://192.168.1.189:7890" --tag ansible-ee-k8s-lite
podman build .\context\ --build-arg PROXY="http://192.168.255.102:7890" --tag ansible-ee-k8s
podman build .\context\ --tag ansible-ee-k8s
```

## Run the ansible container (Ansible Runner)
ref: 
 - [Using Runner as a container interface to Ansible](https://ansible-runner.readthedocs.io/en/stable/container/)
 - [ansible-runner/Dockerfile](https://github.com/ansible/ansible-runner/blob/devel/Dockerfile)
 - [demo](https://github.com/ansible/ansible-runner/tree/devel/demo)

```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\builder)
podman run --rm -e RUNNER_PLAYBOOK=Invoke-xanmanning.k3s.yml -v ../:/runner localhost/ansible-ee-k8s-lite

podman run --rm -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml -v ../:/runner localhost/ansible-ee-k8s-lite
podman run --rm -e RUNNER_PLAYBOOK=Invoke-KubeResource.yml -v ../:/runner localhost/ansible-ee-k8s-lite ansible-runner run /runner -vvvv

podman run --rm -e RUNNER_PLAYBOOK=./debug/Get-HelmInfo.yml -v ../:/runner localhost/ansible-ee-k8s-lite
podman run --rm -e RUNNER_PLAYBOOK=./debug/test.yml -v ../:/runner localhost/ansible-ee-k8s-lite ansible-runner run /runner -vvvv
podman run --rm -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv
podman run --rm -e RUNNER_PLAYBOOK=./debug/Invoke-Terraform.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

# install freeipa server
podman run --rm -e RUNNER_PLAYBOOK=./Invoke-FreeIPA.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv

podman run --rm -e RUNNER_PLAYBOOK=./debug/Update-Hosts.yml -v ../:/runner localhost/ansible-ee-k8s ansible-runner run /runner -vvvv
```