```powershell
# https://stackoverflow.com/questions/19529688/how-to-merge-2-json-objects-from-2-files-using-jq/24904276#24904276
jq -s ".[0] * .[1]" ca.json merge.json
```