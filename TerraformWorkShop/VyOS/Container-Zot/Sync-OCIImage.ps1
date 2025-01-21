$syncList = @"
[
    {
        "publicRegistry": "docker.io",
        "publicRepo": "powerdns/pdns-auth-49:4.9.3",
        "archive": "docker.io_powerdns_pdns-auth-49_4.9.3.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "powerdns/pdns-auth-49:4.9.3",
        "description": "https://hub.docker.com/r/powerdns/pdns-auth-49",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "fedora/postgresql-16:20241225",
        "archive": "quay.io_fedora_postgresql-16_20241225.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "fedora/postgresql-16:20241225",
        "description": "https://quay.io/repository/fedora/postgresql-16?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "sclorg/postgresql-16-c10s:20250108",
        "archive": "quay.io_sclorg_postgresql-16-c10s_20250108.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "sclorg/postgresql-16-c10s:20250108",
        "description": "https://quay.io/repository/sclorg/postgresql-16-c10s?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "cockpit/ws:331",
        "archive": "quay.io_cockpit_ws_331.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "cockpit/ws:331",
        "description": "https://quay.io/repository/cockpit/ws?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "coreos/etcd:v3.5.17",
        "archive": "quay.io_coreos_etcd_v3.5.17.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "coreos/etcd:v3.5.17",
        "description": "https://quay.io/repository/coreos/etcd?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "giantswarm/coredns:1.12.0",
        "archive": "quay.io_giantswarm_coredns_1.12.0.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "coredns/coredns:1.12.0",
        "description": "https://hub.docker.com/r/coredns/coredns/tags, https://quay.io/repository/giantswarm/coredns?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "openidentityplatform/opendj:4.9.1",
        "archive": "docker.io_openidentityplatform_opendj_4.9.1.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "openidentityplatform/opendj:4.9.1",
        "description": "https://hub.docker.com/r/openidentityplatform/opendj/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/vault:1.18",
        "archive": "docker.io_hashicorp_vault_1.18.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "hashicorp/vault:1.18",
        "description": "https://hub.docker.com/r/hashicorp/vault/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "apteno/alpine-jq:2025-01-12",
        "archive": "docker.io_apteno_alpine-jq_2025-01-12.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "apteno/alpine-jq:latest",
        "description": "https://hub.docker.com/r/apteno/alpine-jq/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/consul:1.20",
        "archive": "docker.io_hashicorp_consul_1.20.tar",
        "privateRegistry": "zot.day0.sololab",
        "privateRepo": "hashicorp/consul:1.20",
        "description": "https://hub.docker.com/r/hashicorp/consul/tags",
    },
]
"@

$localDir="$env:PUBLIC/Downloads/containers"
# $localDir="C:/Users/Public/Downloads/containers"
# $localDir="D:/Users/Public/Downloads/containers"
# Test-Path -Path $localDir

$proxy="127.0.0.1:7890"
# $proxy="192.168.255.1:7890"
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

$syncList | ConvertFrom-Json | ForEach-Object {
    if (-not (Test-Path -Path $localDir/$($_.archive))) {
        Write-Host "Download docker image then convert to OCI archive $localDir/$($_.archive)"
        skopeo copy --insecure-policy `
            --override-os=linux `
            --override-arch=amd64 `
            docker://$($_.publicRegistry)/$($_.publicRepo) `
            oci-archive:$localDir/$($_.archive)
    }
}

$proxy=""
$env:HTTP_PROXY=$proxy; $env:HTTPS_PROXY=$proxy

$syncList | ConvertFrom-Json | ForEach-Object {
    if (Test-Path -Path $localDir/$($_.archive)) {
    Write-Host "Upload OCI image OCI archive $localDir/$($_.archive) to $($_.privateRegistry)/$($_.privateRepo)"
    skopeo copy --insecure-policy `
        --dest-tls-verify=false `
        --dest-creds="admin:P@ssw0rd" `
        oci-archive:$localDir/$($_.archive) `
        docker://$($_.privateRegistry)/$($_.privateRepo)
    }
    Start-Sleep -Seconds 1
}