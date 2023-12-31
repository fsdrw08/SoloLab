service {
  id      = "step-ca"
  name    = "step-ca"
  address = "step-ca.service.consul"

  checks = [
    {
      id       = "stepca-tcp-check-443"
      name     = "stepca-tcp-check-443"
      tcp      = "192.168.255.2:9000"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
