services {
  id      = "jenkins-80"
  name    = "jenkins"
  port    = 80

  checks = [
    {
      id       = "jenkins-tcp-check-80"
      name     = "jenkins-tcp-check-80"
      tcp      = "192.168.255.10:80"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}

services {
  id      = "jenkins-443"
  name    = "jenkins"
  port    = 443

  checks = [
    {
      id       = "jenkins-tcp-check-443"
      name     = "jenkins-tcp-check-443"
      tcp      = "192.168.255.10:443"
      interval = "20s"
      timeout  = "2s"
    }
  ]
}
