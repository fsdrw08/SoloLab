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

```