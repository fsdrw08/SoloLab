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
ref: https://docs.podman.io/en/latest/markdown/podman-build.1.html#examples
```powershell
cd (Join-Path (git rev-parse --show-toplevel) AnsibleWorkShop\builder)
# with_proxy
podman build .\context\ --build-arg PROXY="http://192.168.1.189:7890" --tag ansible-ee-aio
podman build .\context\ --build-arg PROXY="http://192.168.255.102:7890" --tag ansible-ee-aio
# with_semi_proxy
# $PROXY="http://10.20.72.21:9999"
$PROXY="http://192.168.255.1:7890"
podman build -f .\context\Containerfile.with_semi_proxy --build-arg PROXY="$PROXY" --tag ansible-ee-aio  .\context\
# without_proxy
podman build .\context\ --tag ansible-ee-aio
```

## Run ansible command in ansible container (Ansible Runner)
ref: 
 - [Introduction to Ansible Runner](https://ansible-runner.readthedocs.io/en/stable/intro/)
 - [Using Runner as a container interface to Ansible](https://ansible-runner.readthedocs.io/en/stable/container/)
 - [ansible-runner/Dockerfile](https://github.com/ansible/ansible-runner/blob/devel/Dockerfile)
 - [demo](https://github.com/ansible/ansible-runner/tree/devel/demo)

```powershell
podman run --rm -v ../:/runner `
   localhost/ansible-ee-aio bash -c "ansible --version"
```