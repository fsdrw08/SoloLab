prov_system = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

prov_vyos = {
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

# https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/opendj-packages/opendj-docker/Dockerfile-alpine
owner = {
  uid = 1001
  gid = 1000
}
