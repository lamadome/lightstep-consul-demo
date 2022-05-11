provider "consul" {
  address    = "consul-quickstart-1651644405175.consul.18ee0ccc-0295-4e79-b048-c0068fe009cc.aws.hashicorp.cloud"
  insecure_https = true
  scheme = "https"
}
resource "consul_acl_policy" "anonymous_metrics_read" {
  name        = "anonymous_metrics_read"
  rules       = <<-RULE
    partition "default" {
        namespace "default"
        {
            agent_prefix "" {
                    policy = "write"
                }
        }
    }
    RULE
}

resource "consul_acl_token_policy_attachment" "attachment" {
    token_id = "00000000-0000-0000-0000-000000000002"
    policy   = "${consul_acl_policy.anonymous_metrics_read.name}"
}