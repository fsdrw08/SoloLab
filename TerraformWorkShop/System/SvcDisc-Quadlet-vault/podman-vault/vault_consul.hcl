services {
  id      = "vault-80"
  name    = "vault"
  port    = 80

  checks = [
    {
      id       = "vault-tcp-check-80"
      name     = "vault-tcp-check-80"
      tcp      = "192.168.255.10:80"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}

services {
  id      = "vault-443"
  name    = "vault"
  port    = 443

  checks = [
    {
      id       = "vault-tcp-check-443"
      name     = "vault-tcp-check-443"
      tcp      = "192.168.255.10:443"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}

// services {
//   id      = "vault"
//   name    = "vault"
//   port    = 80

//   checks = [
//     {
//       id       = "podman-healthcheck-vault"
//       name     = "podman-healthcheck-vault"
//       args      = ["/usr/bin/podman", "healthcheck", "run", "vault-vault"]
//       interval = "20s"
//       timeout  = "2s"
//     }
//   ]
// }