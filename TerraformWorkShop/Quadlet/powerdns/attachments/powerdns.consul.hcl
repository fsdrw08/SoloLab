services {
  name = "powerdns-day0"
  id   = "powerdns-auth"
  port = 8081

  checks = [
    {
      id   = "powerdns-auth-https-check"
      name = "powerdns-auth-https-check"
      # https://doc.powerdns.com/authoritative/http-api/statistics.html
      http = "http://localhost:8081/api/v1/servers/localhost/statistics?statistic=uptime"
      header = {
        X-API-Key = ["powerdns"]
      }
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]
}

services {
  name = "powerdns-day0"
  id   = "powerdns-recursor"
  port = 8082

  checks = [
    # https://doc.powerdns.com/recursor/common/api/endpoint-statistics.html
    {
      id   = "powerdns-recursor-https-check"
      name = "powerdns-recursor-https-check"
      http = "http://localhost:8082/api/v1/servers/localhost/statistics"
      header = {
        X-API-Key = ["powerdns"]
      }
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]
}
# https://doc.powerdns.com/recursor/common/api/endpoint-statistics.html