this module will:
1. (optional) prepare cockroachdb bin file 
2. prepare cockroachdb config dir (recommend to use `/etc/cockroach`)
3. (optional) prepare cockroachdb certs, ref: [Using a custom CA](https://www.cockroachlabs.com/docs/stable/authentication#using-a-custom-ca), you need to config filename and content for below files:
   - `ca.crt`, this is required for both server and client side to verify each other
   - `node.crt` and `node.key` for server side prove itself, e.g. `cockroach start-single-node --certs-dir=xxx`
   - `client.xxx.crt` and `client.xxx.key` for client side prove itself, e.g. `cockroach sql --certs-dir=xxx`   

