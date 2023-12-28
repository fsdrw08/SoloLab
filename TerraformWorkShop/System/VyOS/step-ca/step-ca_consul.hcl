service {
  id      = "stepca"
  name    = "stepca"
  address = "stepca.service.consul"

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
