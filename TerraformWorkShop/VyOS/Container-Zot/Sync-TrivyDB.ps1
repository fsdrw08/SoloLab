# https://github.com/LubinLew/trivy-data-sync/blob/80befc585f54769cfd28cd28fc8d9e541ca4fbee/trivy_sync.sh#L112
$syncList = @"
[
    {
        "publicImage": "ghcr.io/aquasecurity/trivy-db:2",
        "OCIFile": "db.tar.gz",
        "OCIFileMediaType": "application/vnd.aquasec.trivy.db.layer.v1.tar+gzip",
        "ManifestFile": "trivy-db-manifest.json",
        "privateRepo": "aquasecurity/trivy-db:2"
    },
    {
        "publicImage": "ghcr.io/aquasecurity/trivy-java-db:1",
        "OCIFile": "javadb.tar.gz",
        "OCIFileMediaType": "application/vnd.aquasec.trivy.javadb.layer.v1.tar+gzip",
        "ManifestFile": "trivy-javadb-manifest.json",
        "privateRepo": "aquasecurity/trivy-java-db:1"
    }
]
"@

$localDir = "$env:PUBLIC/Downloads/containers/trivy"
# go to local oci archive dir
Set-Location -Path $localDir

# set internet proxy for download
$proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

# pull
$syncList | ConvertFrom-Json | ForEach-Object {
    oras pull $_.publicImage

    # Download manifest
    oras manifest fetch `
    --output $_.ManifestFile `
    $_.publicImage
}

# push
$privateRegistry = "zot.day0.sololab"
$env:HTTP_PROXY=$null; $env:HTTPS_PROXY=$null
# login to zot
oras login -u admin $privateRegistry

# Push the prior downloaded trivy-db to private registry
# https://github.com/aquasecurity/trivy-db/blob/8c398f13db0ed9be333fe1b9ddab158ab7262967/README.md#building-the-db

$trivyArtifactType = "application/vnd.aquasec.trivy.config.v1+json"
$syncList | ConvertFrom-Json | ForEach-Object {
    "oras push"
    oras push `
        --insecure `
        --disable-path-validation `
        --artifact-type $trivyArtifactType `
        $privateRegistry/$($_.privateRepo) `
        "$($_.OCIFile):$($_.OCIFileMediaType)"

    "oras manifest push"
    oras manifest push `
        --insecure `
        $privateRegistry/$($_.privateRepo) `
        $_.ManifestFile

    "oras manifest fetch"
    oras manifest fetch $privateRegistry/$($_.privateRepo)
}