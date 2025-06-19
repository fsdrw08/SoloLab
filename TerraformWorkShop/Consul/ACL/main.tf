resource "consul_acl_policy" "policy" {
  name  = "prometheus"
  rules = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    RULE
}
