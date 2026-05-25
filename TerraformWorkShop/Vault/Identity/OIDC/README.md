config vault as OIDC identity provider

# Note
In case of update scope, this provider resource will prevent scope delete,  
should run `terraform apply -target="vault_identity_oidc_provider.provider"`
to update this resource first
