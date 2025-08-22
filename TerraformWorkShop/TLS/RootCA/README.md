TF IaC to create local root CA and issue an intermediate CA, then use the intermediate CA to sign some certs for early period infrastructure provision usage

After provisioned resources in this dir, install the root.crt to trust ca dir.

To export the CA root cert key bundle(most use case is import the root CA into vault), uncomment the `resource "local_file" "rootca_pem_bundle"` block in `main.tf`, then apply the resource.  
After import  CA root cert key bundle to vault, comment out the `resource "local_file" "rootca_pem_bundle"` block in `main.tf`, save, then apply the resource again.