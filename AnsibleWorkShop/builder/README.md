## To build a ansible execution environment (Ansible EE, aka a container)
0. Pre-request
   - Install RedHat.podman
    ```
    winget install RedHat.podman
    ```

1. Install ansible-builder
   - Create and active python venv
    ```powershell
    python -m venv
    . .\venv\Scripts\active.bat
    ```
   - Install ansible-builder from pip
     - ref: [Chapter 2. Using Ansible Builder](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.0-ea/html-single/ansible_builder_guide/index)

    ```
    pip install ansible-builder
    ```

2. Prepare container build file (Containerfile, aka dockerfile)
   - Generate Containerfile and podman related context with [definition.yml](definition.yml)
   ```
   ansible-builder create -f .\definition.yml 
   ```
   - Fix some syntax (POIXFX) error in the Containerfile

3. Build the ansible runner image
```
podman build .\context\ --build-arg PROXY="http://192.168.1.189:7890" --tag ansible-ee-k8s
```

## Run the ansible container (Ansible Runner)
```
podman run --rm -e RUNNER_PLAYBOOK=test.yml -v $PWD/demo:/runner localhost/ansible-ee-k8s
```