ref: 
- [Authenticating as an admin](https://smallstep.com/docs/step-ca/provisioners/#:~:text=Authenticating%20as%20an%20admin)
- [EXAMPLE CONFIGURATION](https://smallstep.com/docs/step-ca/configuration/#specify-a-configuration-file:~:text=EXAMPLE%20CONFIGURATION)
update acme cert life (default 24h)
```shell
step ca provisioner update acme --x509-max-dur=2160h
#specify-a-configuration-file:~:text=EXAMPLE%20CONFIGURATION
# admin name: step
# provisioner: admin (JWK)
# password: var in DOCKER_STEPCA_INIT_PROVISIONER_NAME
```