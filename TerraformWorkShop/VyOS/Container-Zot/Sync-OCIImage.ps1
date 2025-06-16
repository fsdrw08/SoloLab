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
        "publicRepo": "cockpit/ws:337",
        "archive": "quay.io_cockpit_ws_337.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "cockpit/ws:337",
        "description": "https://quay.io/repository/cockpit/ws?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hectorm/nfs-ganesha:v9",
        "archive": "docker.io_hectorm_nfs-ganesha_v9.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hectorm/nfs-ganesha:v9",
        "description": "https://hub.docker.com/r/hectorm/nfs-ganesha/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "lldap/lldap:2025-05-19-alpine-rootless",
        "archive": "docker.io_lldap_lldap_2025-05-19-alpine-rootless.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "lldap/lldap:2025-05-19-alpine-rootless",
        "description": "https://hub.docker.com/r/lldap/lldap/tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "coreos/etcd:v3.6.0",
        "archive": "quay.io_coreos_etcd_v3.6.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "coreos/etcd:v3.6.0",
        "description": "https://quay.io/repository/coreos/etcd?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "giantswarm/coredns:1.12.1",
        "archive": "quay.io_giantswarm_coredns_1.12.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "coredns/coredns:1.12.1",
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
        "publicRepo": "hashicorp/vault:1.19.4",
        "archive": "docker.io_hashicorp_vault_1.19.4.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/vault:1.19.4",
        "description": "https://hub.docker.com/r/hashicorp/vault/tags",
    },
    {
        "publicRegistry": "ghcr.io",
        "publicRepo": "dexidp/example-app:latest",
        "archive": "ghcr.io_dexidp_example-app_latest.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "dexidp/example-app:latest",
        "description": "https://github.com/dexidp/dex/pkgs/container/example-app",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "apteno/alpine-jq:2025-05-18",
        "archive": "docker.io_apteno_alpine-jq_2025-05-18.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "apteno/alpine-jq:latest",
        "description": "https://hub.docker.com/r/apteno/alpine-jq/tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "minio/minio:RELEASE.2025-04-22T22-12-26Z",
        "archive": "quay.io_minio_minio_RELEASE.2025-04-22T22-12-26Z.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "minio/minio:RELEASE.2025-04-22T22-12-26Z",
        "description": "https://quay.io/repository/minio/minio?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/consul:1.21.1",
        "archive": "docker.io_hashicorp_consul_1.21.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/consul:1.21.1",
        "description": "https://hub.docker.com/r/hashicorp/consul/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "hashicorp/nomad:1.10.0",
        "archive": "docker.io_hashicorp_nomad_1.10.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "hashicorp/nomad:1.10.0",
        "description": "https://hub.docker.com/r/hashicorp/nomad/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "multani/nomad:1.10.0",
        "archive": "docker.io_multani_nomad_1.10.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "multani/nomad:1.10.0",
        "description": "https://hub.docker.com/r/multani/nomad/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "library/traefik:v3.4.1",
        "archive": "docker.io_library_traefik_v3.4.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "library/traefik:v3.4.1",
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
    {
        "publicRegistry": "docker.io",
        "publicRepo": "grafana/grafana:12.0.1",
        "archive": "docker.io_grafana_grafana_12.0.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "grafana/grafana:12.0.1",
        "description": "https://hub.docker.com/r/grafana/grafana/tags, https://quay.io/repository/giantswarm/grafana?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "grafana/loki:3.5.1",
        "archive": "docker.io_grafana_loki_3.5.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "grafana/loki:3.5.1",
        "description": "https://hub.docker.com/r/grafana/loki/tags, https://quay.io/repository/giantswarm/loki?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "bitnami/grafana-loki:3.5.1",
        "archive": "docker.io_bitnami_grafana-loki_3.5.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "bitnami/grafana-loki:3.5.1",
        "description": "https://hub.docker.com/r/bitnami/grafana-loki/tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "grafana/alloy:v1.8.3",
        "archive": "docker.io_grafana_alloy_v1.8.3.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "grafana/alloy:v1.8.3",
        "description": "https://hub.docker.com/r/grafana/alloy/tags, https://quay.io/repository/giantswarm/alloy?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "prometheus/prometheus:v3.4.1",
        "archive": "quay.io_prometheus_prometheus_v3.4.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "prometheus/prometheus:v3.4.1",
        "description": "https://hub.docker.com/r/prom/prometheus/tags, https://quay.io/repository/prometheus/prometheus?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "bitnami/prometheus:3.4.1",
        "archive": "docker.io_bitnami_prometheus_3.4.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "bitnami/prometheus:3.4.1",
        "description": "https://hub.docker.com/r/bitnami/prometheus/tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "prometheus/alertmanager:v0.28.1",
        "archive": "quay.io_prometheus_alertmanager_v0.28.1.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "prometheus/alertmanager:v0.28.1",
        "description": "https://hub.docker.com/r/prom/prometheus/tags, https://quay.io/repository/prometheus/prometheus?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "navidys/prometheus-podman-exporter:v1.17.0",
        "archive": "quay.io_navidys_prometheus-podman-exporter_v1.17.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "navidys/prometheus-podman-exporter:v1.17.0",
        "description": "https://quay.io/repository/navidys/prometheus-podman-exporter?tab=tags",
    },
    {
        "publicRegistry": "quay.io",
        "publicRepo": "prometheus/blackbox-exporter:v0.26.0",
        "archive": "quay.io_prometheus_blackbox-exporter_v0.26.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "prometheus/blackbox-exporter:v0.26.0",
        "description": "https://quay.io/repository/prometheus/blackbox-exporter?tab=tags",
    },
    {
        "publicRegistry": "docker.io",
        "publicRepo": "bitnami/blackbox-exporter:0.26.0",
        "archive": "docker.io_bitnami_blackbox-exporter_0.26.0.tar",
        "privateRegistry": "192.168.255.10:5000",
        "privateRepo": "bitnami/blackbox-exporter:0.26.0",
        "description": "https://hub.docker.com/r/bitnami/blackbox-exporter/tags",
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