This Terraform code will deploy [zot](https://github.com/project-zot/zot) as a container under vyos vm instance

zot has ability to scan CVE (Common Vulnerabilities and Exposures), by default it will download trivy-db from `ghcr.io/project-zot/trivy-db`.  

If we are in a restrict environment, no internet access, we can config zot to download trivy-db from some other place, e.g. download from zot itself, here are the config process to make zot download trivy-db from itself:

ref: 
- https://github.com/project-zot/zot/issues/2298 
- https://github.com/aquasecurity/trivy/issues/4169
- https://github.com/aquasecurity/trivy/discussions/4194
1. set config `extensions.search.cve.trivy.dbrepository` to zot itself's oci url, in this case: `zot.day0.sololab/aquasecurity/trivy-db`
    ```jsonc
    {
        "extensions": {
            "search": {
                "cve": {
                    "trivy": {
                        "javadbrepository": "zot.day0.sololab/aquasecurity/trivy-java-db",
                        "dbrepository": "zot.day0.sololab/aquasecurity/trivy-db",
                    }
                }
            }
        }
    }
    ```

2. for the reason that this deploy configured private ca tls in zot http:
    ```json
    {
        "http": {
            "...": "...",
            "tls": {
                "cert": "/etc/zot/certs/server.crt",
                "key": "/etc/zot/certs/server.key",
                "cacert": "/etc/zot/certs/ca.crt",
            }
        }
    }
    ```
    and the trivy-db download process is done by trivy lib in zot, in order to make
    trivy lib trust private CA, need to add env var `SSL_CERT_DIR`, set value to the private ca related cert dir, in this case: `/etc/zot/certs`

3. after zot up and running, upload trivy-db into zot, pre-request: [oras](https://oras.land/docs/installation) installed 

    ```powershell
    # 1. Install oras in windows by winget
    winget install ORASProject.ORAS
    # or scoop (recommend)
    scoop install oras

    # https://github.com/LubinLew/trivy-data-sync/blob/ 80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
    $privateRegistry = "zot.day0.sololab"
    $privateRepo = "aquasecurity/trivy-db:2"
    $publicImage = "ghcr.io/aquasecurity/trivy-db:2"
    $localDir = "$env:PUBLIC/Downloads/containers/trivy"

    # login to zot
    oras login -u admin $privateRegistry

    # go to local oci archive dir
    Set-Location -Path $localDir

    # set internet proxy for download
    $proxy="127.0.0.1:7890"
    $env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

    # Download the trivy-db
    oras pull $publicImage

    # Download the manifest for trivy-db
    oras manifest fetch `
        --output trivy-db-manifest.json `
        $publicImage

    # Push the prior downloaded trivy-db to private registry
    $env:HTTP_PROXY=$null; $env:HTTPS_PROXY=$null
    oras push `
        --insecure `
        --disable-path-validation `
        $privateRegistry/$privateRepo `
        db.tar.gz:application/vnd.aquasec.trivy.db.layer.v1.tar+gzip

    oras manifest push `
        --insecure `
        $privateRegistry/$privateRepo `
        trivy-db-manifest.json

    # verify
    oras manifest fetch $privateRegistry/$privateRepo
    ```

Sync container image from public to private
### use skopeo directly 
```powershell
podman run --rm quay.io/skopeo/stable copy `
    docker://docker.io/hashicorp/consul:1.18.1 `
    docker://zot.day0.sololab/hashicorp/consul:1.18.1 `
    --dest-tls-verify=false `
    --dest-creds=admin:P@ssw0rd

podman run --rm quay.io/skopeo/stable copy –override-arch=amd64 –override-os=linux `
    --dest-compress-format gzip `
    --dest-tls-verify=false `
    --dest-creds=admin:P@ssw0rd
    docker://docker.io/hashicorp/consul:1.18.1 `
    oci-archive://zot.day0.sololab/hashicorp/consul:1.18.1 `

```

```powershell
# https://github.com/passcod/winskopeo
# https://github.com/containers/skopeo/issues/394
# https://github.com/containers/skopeo/blob/main/docs/skopeo.1.md#image-names
$publicRegistry="quay.io"
$image="cockpit/ws:329"
$archive="quay.io_cockpit_ws_327.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="docker.io"
$image="hashicorp/vault:1.16.3"
$archive="hashicorp_vault_1.16.3.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="docker.io"
$image="hashicorp/consul:1.18.2"
$archive="hashicorp_consul_1.18.2.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="docker.io"
$image="library/traefik:v3.0.1"
$archive="library_traefik_v3.0.1.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="docker.io"
$image="traefik/whoami:v1.10.2"
$archive="traefik_whoami_v1.10.2.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="docker.io"
$image="coredns/coredns:1.11.1"
$archive="coredns_coredns_1.11.1tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="quay.io"
$image="ceph/daemon:latest-main"
$archive="quay.io.ceph_daemon_latest-main.tar"
$privateRegistry="zot.day0.sololab"

$publicRegistry="quay.io"
$image="fedora/postgresql-16:20241127"
$archive="quay.io_fedora_postgresql-16_20241127.tar"
$privateRegistry="zot.day0.sololab"

$proxy="127.0.0.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

skopeo copy --insecure-policy `
    --override-os=linux `
    --override-arch=amd64 `
    docker://$publicRegistry/$image `
    oci-archive:$env:PUBLIC/Downloads/containers/$archive

$proxy=""
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
skopeo copy --insecure-policy `
    --src-tls-verify=false `
    --dest-creds=admin:P@ssw0rd `
    oci-archive:$env:PUBLIC/Downloads/containers/$archive `
    docker://$privateRegistry/$image




# https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
oras login -u admin zot.day0.sololab
Set-Location -Path $env:PUBLIC/Downloads/containers/trivy
# trivy-db
# Download the trivy-db
oras pull ghcr.io/aquasecurity/trivy-db:2

# Download the manifest for trivy-db
oras manifest fetch `
    --output trivy-db-manifest.json `
    ghcr.io/aquasecurity/trivy-db:2

# Push the prior downloaded trivy-db to your registry
oras push `
    --insecure `
    --disable-path-validation `
    zot.day0.sololab/aquasecurity/trivy-db:2 `
    db.tar.gz:application/vnd.aquasec.trivy.db.layer.v1.tar+gzip

oras manifest push `
    --insecure `
    zot.day0.sololab/aquasecurity/trivy-db:2 `
    trivy-db-manifest.json

oras manifest fetch zot.day0.sololab/aquasecurity/trivy-db:2

# trivy-java-db
oras pull ghcr.io/aquasecurity/trivy-java-db:1

oras manifest fetch `
    --output trivy-java-db-manifest.json `
    ghcr.io/aquasecurity/trivy-db:2

oras push `
    --disable-path-validation `
    zot.day0.sololab/aquasecurity/trivy-java-db:1 `
    javadb.tar.gz:application/vnd.aquasec.trivy.javadb.layer.v1.tar+gzip

oras manifest push `
    zot.day0.sololab/aquasecurity/trivy-java-db:1 `
    trivy-java-db-manifest.json

oras manifest fetch zot.day0.sololab/aquasecurity/trivy-java-db:1


```