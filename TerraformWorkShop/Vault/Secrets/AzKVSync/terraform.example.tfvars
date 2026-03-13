prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_azurerm = {
  subscription_id = "7822fcf9-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # <corp><region>-prd-001
}

kvv2_secrets = [
  {
    mount        = "kvv2_others"
    name         = "azure-sp-cred_exporter"
    data_version = 202603041409
    secret_sets = [
      {
        key = "client_id"
        value_ref_az_kv = {
          key_vault_id = "/subscriptions/7b300b26-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-<corp><region>dts-prd-001/providers/Microsoft.KeyVault/vaults/kv-<corp><region>dts-prd-001"
          name         = "entra-app-AzureMonitorMetricsExporter-2f374779-clientId"
        }
      },
      {
        key = "client_secret"
        value_ref_az_kv = {
          key_vault_id = "/subscriptions/7b300b26-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-<corp><region>dts-prd-001/providers/Microsoft.KeyVault/vaults/kv-<corp><region>dts-prd-001"
          name         = "entra-app-AzureMonitorMetricsExporter-2f374779-sp-password"
        }
      },
      {
        key          = "tenant_id"
        value_string = "368f27ae-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      },
    ]
  }
]
