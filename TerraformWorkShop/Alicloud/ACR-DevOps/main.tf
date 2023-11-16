resource "alicloud_cr_namespace" "acr_ns" {
  for_each = {
    for ns in var.acr_namespaces : ns.name => ns
  }
  name               = each.key
  auto_create        = each.value.auto_create
  default_visibility = each.value.default_visibility
}

locals {
  acr_repos = flatten([
    for ns in var.acr_namespaces : [
      for repo in ns.repos : {
        ns_name   = ns.name
        name      = repo.name
        summary   = repo.summary
        repo_type = repo.repo_type
        detail    = repo.detail
      }
    ]
  ])
}

resource "alicloud_cr_repo" "acr_repo" {
  depends_on = [alicloud_cr_namespace.acr_ns]
  for_each = {
    for repo in local.acr_repos : repo.name => repo
  }
  namespace = each.value.ns_name
  name      = each.key
  summary   = each.value.summary
  repo_type = each.value.repo_type
  detail    = each.value.detail
}
