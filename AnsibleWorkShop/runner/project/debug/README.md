```powershell
# debug helm template
cd "$(git rev-parse --show-toplevel)\AnsibleWorkShop\runner"
$private_data_dir = "/tmp/private"
podman run --rm --userns=keep-id `
    -e RUNNER_PLAYBOOK=./debug/Render-HelmTemplate.yml `
    -v ./:$private_data_dir `
    -v ../../KubeWorkShop/:/KubeWorkShop/ `
    -v ../../HelmWorkShop/:/HelmWorkShop/ `
    localhost/ansible-ee-aio-new `
    bash -c "ansible-runner run $private_data_dir -vv"
```