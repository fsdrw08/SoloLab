service {
  id      = "step-ca"
  name    = "step-ca"
  port    = 8443

  checks = [
    {
      id       = "stepca-tcp-check-8443"
      name     = "stepca-tcp-check-8443"
      tcp      = "192.168.255.2:8443"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
