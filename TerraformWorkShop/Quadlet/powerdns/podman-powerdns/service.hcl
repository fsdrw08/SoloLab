services {
  id   = "powerdns-auth-web"
  name = "powerdns-auth"
  port = 8081

  checks = [
    {
      id   = "powerdns-auth-https-check"
      name = "powerdns-auth-https-check"
      # https://doc.powerdns.com/authoritative/http-api/statistics.html
      http = "https://pdns-auth.day0.sololab/api/v1/servers/localhost/statistics?statistic=uptime"
      header = {
        X-API-Key = ["powerdns"]
      }
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]
}

services {
  id   = "powerdns-recursor-web"
  name = "powerdns-recursor"
  port = 8082

  checks = [
    # https://doc.powerdns.com/recursor/common/api/endpoint-statistics.html
    {
      id   = "powerdns-recursor-https-check"
      name = "powerdns-recursor-https-check"
      http = "https://pdns-recursor.day0.sololab/api/v1/servers/localhost/statistics"
      header = {
        X-API-Key = ["powerdns"]
      }
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]
}
# https://doc.powerdns.com/recursor/common/api/endpoint-statistics.html