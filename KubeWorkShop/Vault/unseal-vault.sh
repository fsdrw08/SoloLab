keys="
{{ vault_unseal_keys_b64 }}
"
for i in $keys
do
    vault operator unseal $i
    sleep 2
done