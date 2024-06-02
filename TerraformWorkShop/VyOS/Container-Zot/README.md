after deploy (terraform apply), and also ensure that ldap entry applied into target ldap server, see [..\..\LDAP\opendj](../../LDAP/opendj/)

#### push image into ora
```powershell
# 1. Install `oras`
winget install ORASProject.ORAS

# 2. Login 
$toRegistry="zot.mgmt.sololab"
$user="admin"
oras login $toRegistry -u $user

# 3. Pull and save image via podman
# ref: https://github.com/oras-project/oras/issues/453#issuecomment-1398141778
# https://github.com/oras-project/oras/issues/1160
# can only download layers to local dir
$platform="linux/amd64"
$fromRegistry="docker.io"
$imageInfo="hashicorp/consul:1.18.1"
$saveTarget="/mnt/data/offline/images/hashicorp_consul_1.18.1.oci.tar"
# $outputDir="C:\Users\WindomWu\Downloads\oras"
podman pull $fromRegistry/$imageInfo
podman save --format oci-archive --output $saveTarget $fromRegistry/$imageInfo


# 4. push
$toRegistry="zot.mgmt.sololab"
$imageInfo="cockroachdb/cockroach:v23.2.4"
# $ociTarFile="C:\Users\WindomWu\Downloads\docker.io_hashicorp_vault_1.16.2.oci.tar"
$ociTarFile="C:\Users\WindomWu\Downloads\cockroachdb_cockroach_v23.2.4.oci.tar"
oras push --disable-path-validation `
    $toRegistry/$imageInfo `
    $ociTarFile
```

### or use skopeo directly 
```powershell
podman run --rm quay.io/skopeo/stable copy `
    docker://docker.io/hashicorp/consul:1.18.1 `
    docker://zot.mgmt.sololab/hashicorp/consul:1.18.1 `
    --dest-tls-verify=false `
    --dest-creds=admin:P@ssw0rd

podman run --rm quay.io/skopeo/stable copy –override-arch=amd64 –override-os=linux `
    --dest-compress-format gzip `
    --dest-tls-verify=false `
    --dest-creds=admin:P@ssw0rd
    docker://docker.io/hashicorp/consul:1.18.1 `
    oci-archive://zot.mgmt.sololab/hashicorp/consul:1.18.1 `

```

```powershell
# https://github.com/passcod/winskopeo
# https://github.com/containers/skopeo/issues/394
# https://github.com/containers/skopeo/blob/main/docs/skopeo.1.md#image-names
$publicRegistry="quay.io"
$image="cockpit/ws:316"
$archive="cockpit_ws_316.tar"
$privateRegistry="zot.mgmt.sololab"

$publicRegistry="docker.io"
$image="hashicorp/vault:1.16.3"
$archive="hashicorp_vault_1.16.3.tar"
$privateRegistry="zot.mgmt.sololab"
skopeo copy --insecure-policy `
    --override-os=linux `
    --override-arch=amd64 `
    docker://$publicRegistry/$image `
    oci-archive:$env:PUBLIC/Downloads/containers/$archive

skopeo copy --insecure-policy `
    --dest-creds=admin:P@ssw0rd `
    oci-archive:$env:PUBLIC/Downloads/containers/$archive `
    docker://$privateRegistry/$image




# https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
oras login -u admin zot.mgmt.sololab
Set-Location -Path $env:PUBLIC/Downloads/containers/
# trivy-db
# Download the trivy-db
oras pull ghcr.io/aquasecurity/trivy-db:2

# Download the manifest for trivy-db
oras manifest fetch `
    --output trivy-db-manifest.json `
    ghcr.io/aquasecurity/trivy-db:2

# Push the prior downloaded trivy-db to your registry
oras push `
    --disable-path-validation `
    zot.mgmt.sololab/aquasecurity/trivy-db:2 `
    db.tar.gz:application/vnd.aquasec.trivy.db.layer.v1.tar+gzip

oras manifest push `
    zot.mgmt.sololab/aquasecurity/trivy-db:2 `
    trivy-db-manifest.json

oras manifest fetch zot.mgmt.sololab/aquasecurity/trivy-db:2

# trivy-java-db
oras pull ghcr.io/aquasecurity/trivy-java-db:1

oras manifest fetch `
    --output trivy-java-db-manifest.json `
    ghcr.io/aquasecurity/trivy-db:2

oras push `
    --disable-path-validation `
    zot.mgmt.sololab/aquasecurity/trivy-java-db:1 `
    javadb.tar.gz:application/vnd.aquasec.trivy.javadb.layer.v1.tar+gzip

oras manifest push `
    zot.mgmt.sololab/aquasecurity/trivy-java-db:1 `
    trivy-java-db-manifest.json

oras manifest fetch zot.mgmt.sololab/aquasecurity/trivy-java-db:1


```