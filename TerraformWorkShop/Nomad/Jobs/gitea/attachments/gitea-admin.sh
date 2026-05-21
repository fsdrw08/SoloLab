#!/usr/bin/env bash

# https://github.com/cmu-sei/foundry-appliance/blob/5ba264cda03d4dcb89d28ba58dabc273b71ad75e/foundry/charts/foundry/templates/job.yaml#L61
if /usr/local/bin/gitea admin auth list | grep -q "Vault"; then
    echo "OAuth auth source 'Vault' already exists, skipping creation"
    echo "To update the config, run `gitea admin auth update-oauth --id x ...`"

    exit 0
fi

/usr/local/bin/gitea migrate

/usr/local/bin/gitea admin auth add-oauth \
    --name "Vault" \
    --provider openidConnect \
    --key "{{ with secret "kvv2_vault/data/oidc-client_gitea" }}{{.Data.data.client_id}}{{ end }}" \
    --secret "{{ with secret "kvv2_vault/data/oidc-client_gitea" }}{{.Data.data.client_secret}}{{ end }}" \
    --auto-discover-url "{{ with secret "kvv2_vault/data/oidc-provider_sololab" }}{{.Data.data.config_url}}{{ end }}" \
    --scopes "openid profile email groups" \
    --group-claim-name "groups" \
    --admin-group "app-gitea-admin"