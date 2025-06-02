data "vault_identity_oidc_openid_config" "config" {
  name = "sololab"
}

data "vault_identity_oidc_client_creds" "creds" {
  name = "grafana"
}

# load cert from vault
data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.tls.vault_kvv2 == null ? 0 : 1
  mount = var.podman_kube.helm.tls.vault_kvv2.mount
  name  = var.podman_kube.helm.tls.vault_kvv2.name
}

# load cert from local tls
# data "terraform_remote_state" "root_ca" {
#   count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
#   backend = var.podman_kube.helm.tls.tfstate.backend.type
#   config  = var.podman_kube.helm.tls.tfstate.backend.config
# }

# locals {
#   cert = var.podman_kube.helm.tls.tfstate == null ? null : [
#     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
#     if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
#   ]
# }

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.value_file)}"
  ]

  # v2 helm provider
  # normal values
  # set = local.helm_value_sets
  # dynamic "set" {
  #   for_each = var.podman_kube.helm.value_sets == null ? [] : flatten([var.podman_kube.helm.value_sets])
  #   content {
  #     name = set.value.name
  #     value = set.value.value_string != null ? set.value.value_string : templatefile(
  #       "${set.value.value_template_path}", "${set.value.value_template_vars}"
  #     )
  #   }
  # }
  # # tls
  # dynamic "set" {
  #   for_each = var.podman_kube.helm.tls == null ? [] : flatten([var.podman_kube.helm.tls.value_sets])
  #   content {
  #     name  = set.value.name
  #     value = local.cert[0][set.value.value_ref_key]
  #   }
  # }

  # v3 helm provider
  set = flatten([
    var.podman_kube.helm.value_sets == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.value_sets]) : {
        name = value_set.name
        value = value_set.value_string != null ? value_set.value_string : templatefile(
          "${value_set.value_template_path}", "${value_set.value_template_vars}"
        )
      }
    ],
    var.podman_kube.helm.tls == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.tls.value_sets]) : {
        name = value_set.name
        # value = local.cert[0][value_set.value_ref_key]
        value = data.vault_kv_secret_v2.cert[0].data[value_set.value_ref_key]
      }
    ],
    # https://github.com/ordiri/ordiri/blob/e18120c4c00fa45f771ea01a39092d6790f16de8/manifests/platform/monitoring/base/kustomization.yaml#L132
    # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/generic-oauth/#steps
    flatten([
      {
        name  = "grafana.configFiles.custom.auth\\.generic_oauth.client_id"
        value = data.vault_identity_oidc_client_creds.creds.client_id
      },
      {
        name  = "grafana.configFiles.custom.auth\\.generic_oauth.client_secret"
        value = data.vault_identity_oidc_client_creds.creds.client_secret
      },
      {
        name  = "grafana.configFiles.custom.auth\\.generic_oauth.auth_url"
        value = "${data.vault_identity_oidc_openid_config.config.authorization_endpoint}?with=ldap"
      },
      {
        name  = "grafana.configFiles.custom.auth\\.generic_oauth.api_url"
        value = data.vault_identity_oidc_openid_config.config.userinfo_endpoint
      },
      {
        name  = "grafana.configFiles.custom.auth\\.generic_oauth.token_url"
        value = data.vault_identity_oidc_openid_config.config.token_endpoint
      },
    ])
  ])
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
}

module "podman_quadlet" {
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    service = {
      name           = var.podman_quadlet.service.name
      status         = var.podman_quadlet.service.status
      custom_trigger = md5(remote_file.podman_kube.content)
    }
    files = [
      for file in var.podman_quadlet.files :
      {
        content = templatefile(
          file.template,
          file.vars
        )
        path = join("/", [
          var.podman_quadlet.dir,
          join(".", [
            var.podman_quadlet.service.name,
            split(".", basename(file.template))[1]
          ])
        ])
      }
    ]
  }
}

resource "powerdns_record" "records" {
  for_each = {
    for record in var.dns_records : record.name => record
  }
  zone    = each.value.zone
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

resource "remote_file" "traefik_file_provider" {
  path    = "/var/home/podmgr/traefik-file-provider/grafana-traefik.yaml"
  content = file("./podman-grafana/grafana-traefik.yaml")
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-grafana.hcl"
  content = file("./podman-grafana/service.hcl")
}
