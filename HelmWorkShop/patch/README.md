test kubectl patch json function
```
kubectl patch ingress loginapp --type='json' --patch-file .\HelmWorkShop\patch\patch.json --dry-run=server -n dex -o yaml
```