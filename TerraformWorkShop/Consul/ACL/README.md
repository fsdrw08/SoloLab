tf resources in this dir are used to manage consul acl policy rule, acl role, acl token, and store acl token to vault kvv2 secret backend,  
and also config Vault as consul CA provider, use vault app role to let consul auto renew vault token, and use this token to apply, renew cert for consul internal communication.

ACL resource relationship mapping:
any policies -> one role -> one token -> vault kvv2 secret backend (optional)
