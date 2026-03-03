prov_nomad = {
  address     = "https://nomad.day1.sololab"
  skip_verify = true
}

jobs = [
  {
    path = "./attachments/nexus3.nomad.hcl"
    var_sets = [
      {
        name = "metrics_auth_header"
        # bWV0cmljczpQQHNzdzByZA== is the base64 encoding of "metrics:P@ssw0rd"
        value_string = "Basic bWV0cmljczpQQHNzdzByZA=="
      },
    ]
  },
]
