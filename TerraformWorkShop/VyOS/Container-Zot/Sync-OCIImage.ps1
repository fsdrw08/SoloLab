$syncList = @"
[
    {
        "publicRegistry": "quay.io",
        "publicRepo": "giantswarm/zot:v2.1.2",
        "archive": "quay.io_giantswarm_zot-v2.1.2.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "giantswarm/zot:v2.1.2",
        "description": "https://quay.io/repository/giantswarm/zot?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "powerdns/pdns-auth-49:4.9.4",
        "archive": "docker.io_powerdns_pdns-auth-49_4.9.4.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "powerdns/pdns-auth-49:4.9.4",
        "description": "https://hub.docker.com/r/powerdns/pdns-auth-49",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "powerdns/pdns-recursor-49:4.9.9",
        "archive": "docker.io_powerdns_pdns-recursor-49_4.9.9.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "powerdns/pdns-recursor-49:4.9.9",
        "description": "https://hub.docker.com/r/powerdns/pdns-recursor-49",
    },
    {
        "publicRegistry": "docker.cloudsmith.io",
        "publicRepo": "isc/docker/kea-dhcp4:2.7.7-20250326",
        "archive": "docker.cloudsmith.io_isc_docker_kea-dhcp4_2.7.7-20250326.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "isc/docker/kea-dhcp4:2.7.7-20250326",
        "description": "https://cloudsmith.io/~isc/repos/docker/packages/detail/docker/kea-dhcp4/#versions",
    },
    {
        "publicRegistry": "docker.cloudsmith.io",
        "publicRepo": "isc/docker/kea-dhcp-ddns:2.7.7-20250326",
        "archive": "docker.cloudsmith.io_isc_docker_kea-dhcp-ddns_2.7.7-20250326.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "isc/docker/kea-dhcp-ddns:2.7.7-20250326",
        "description": "https://cloudsmith.io/~isc/repos/docker/packages/detail/docker/kea-dhcp-ddns/#versions",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "fedora/postgresql-16:20241225",
        "archive": "quay.io_fedora_postgresql-16_20241225.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "fedora/postgresql-16:20241225",
        "description": "https://quay.io/repository/fedora/postgresql-16?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "sclorg/postgresql-16-c10s:20250108",
        "archive": "quay.io_sclorg_postgresql-16-c10s_20250108.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "sclorg/postgresql-16-c10s:20250108",
        "description": "https://quay.io/repository/sclorg/postgresql-16-c10s?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "cockpit/ws:333",
        "archive": "quay.io_cockpit_ws_333.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "cockpit/ws:333",
        "description": "https://quay.io/repository/cockpit/ws?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "coreos/etcd:v3.5.17",
        "archive": "quay.io_coreos_etcd_v3.5.17.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "coreos/etcd:v3.5.17",
        "description": "https://quay.io/repository/coreos/etcd?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "giantswarm/coredns:1.12.0",
        "archive": "quay.io_giantswarm_coredns_1.12.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "coredns/coredns:1.12.0",
        "description": "https://hub.docker.com/r/coredns/coredns/tags, https://quay.io/repository/giantswarm/coredns?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "openidentityplatform/opendj:4.9.1",
        "archive": "docker.io_openidentityplatform_opendj_4.9.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "openidentityplatform/opendj:4.9.1",
        "description": "https://hub.docker.com/r/openidentityplatform/opendj/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/vault:1.18",
        "archive": "docker.io_hashicorp_vault_1.18.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/vault:1.18",
        "description": "https://hub.docker.com/r/hashicorp/vault/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "apteno/alpine-jq:2025-01-12",
        "archive": "docker.io_apteno_alpine-jq_2025-01-12.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "apteno/alpine-jq:latest",
        "description": "https://hub.docker.com/r/apteno/alpine-jq/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/consul:1.20",
        "archive": "docker.io_hashicorp_consul_1.20.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/consul:1.20",
        "description": "https://hub.docker.com/r/hashicorp/consul/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/nomad:1.9",
        "archive": "docker.io_hashicorp_nomad_1.9.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/nomad:1.9",
        "description": "https://hub.docker.com/r/hashicorp/nomad/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "multani/nomad:1.9.6",
        "archive": "docker.io_multani_nomad_1.9.6.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "multani/nomad:1.9.6",
        "description": "https://hub.docker.com/r/multani/nomad/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "library/traefik:v3.3.4",
        "archive": "docker.io_library_traefik_v3.3.4.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "library/traefik:v3.3.4",
        "description": "https://hub.docker.com/r/library/traefik/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "traefik/whoami:v1.10",
        "archive": "docker.io_traefik_whoami_v1.10.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "traefik/whoami:v1.10",
        "description": "https://hub.docker.com/r/traefik/whoami/tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "instrumentisto/rsync-ssh:alpine3.21",
        "archive": "quay.io_instrumentisto_rsync-ssh_alpine3.21.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "instrumentisto/rsync-ssh:alpine3.21",
        "description": "https://quay.io/repository/instrumentisto/rsync-ssh?tab=tags",
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