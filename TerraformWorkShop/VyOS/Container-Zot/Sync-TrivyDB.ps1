# https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
oras login -u admin zot.day0.sololab
Set-Location -Path $env:PUBLIC/Downloads/containers/trivy
# trivy-db
# Download the trivy-db
$proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

oras pull ghcr.io/aquasecurity/trivy-db:2

# Download the manifest for trivy-db
oras manifest fetch `
    --output trivy-db-manifest.json `
    ghcr.io/aquasecurity/trivy-db:2

# Push the prior downloaded trivy-db to your registry
$proxy=""
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy
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