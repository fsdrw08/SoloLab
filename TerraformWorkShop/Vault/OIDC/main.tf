data "vault_identity_group" "minio_default" {
  group_name = "minio-default"
}

resource "vault_identity_oidc_assignment" "minio" {
  name = "oidc-minio"
  group_ids = [
    data.vault_identity_group.minio_default.group_id
  ]
}

resource "vault_identity_oidc_client" "minio" {
  name = "minio"

}
