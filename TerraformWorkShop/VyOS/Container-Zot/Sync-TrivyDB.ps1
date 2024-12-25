# https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
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
# https://github.com/aquasecurity/trivy-db/blob/8c398f13db0ed9be333fe1b9ddab158ab7262967/README.md#building-the-db
oras push `
    --insecure `
    --disable-path-validation `
    --artifact-type application/vnd.aquasec.trivy.config.v1+json `
    $privateRegistry/$privateRepo `
    db.tar.gz:application/vnd.aquasec.trivy.db.layer.v1.tar+gzip `

oras manifest push `
    --insecure `
    $privateRegistry/$privateRepo `
    trivy-db-manifest.json

# verify
oras manifest fetch $privateRegistry/$privateRepo