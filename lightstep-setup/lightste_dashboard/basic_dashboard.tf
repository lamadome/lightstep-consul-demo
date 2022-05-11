terraform {
  required_providers {
    lightstep = {
      source = "lightstep/lightstep"
      version = "1.60.3"
    }
  }
}

provider "lightstep" {
  api_key         = var.lightstep_api_key
  organization    = var.lightstep_org
}
resource "lightstep_metric_dashboard" "consul_dashboard" {
  project_name = var.project
  dashboard_name = "Consul and Envoy Metrics"
  chart {
    name = "Consul-frontend-envoy"
    rank = "0"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      metric              = "envoy_cluster_external_upstream_rq"
      timeseries_operator = "rate"
      include_filters = [
        {
          key   = "app"
          value = "frontend"
        }
      ]
      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }

  }
  chart {
    name = "product api send/receive"
    rank = "1"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      metric              = "envoy_cluster_external_upstream_rq"
      timeseries_operator = "rate"
      include_filters = [
        {
          key   = "app"
          value = "product-api"
        }
      ]
      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }

  }
  chart {
    name = "Public API Queries"
    rank = "2"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      spans {
         query         = "service IN (\"public-api\")"
         operator      = "latency"
         group_by_keys = []
         latency_percentiles = [50,95,99,99.9,]
      }

    }

  }

  chart {
    name = "Payments API Queries"
    rank = "3"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      spans {
         query         = "service IN (\"payments\")"
         operator      = "latency"
         group_by_keys = []
         latency_percentiles = [50,95,99,99.9,]
      }

    }

  }
  chart {
    name = "Memberlist gossip"
    rank = "4"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "bar"
      hidden              = false

      metric              = "consul_memberlist_gossip_sum"
      timeseries_operator = "rate"
      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }

  }
}

resource "lightstep_metric_dashboard" "exported_dashboard" {
  project_name = var.project
  dashboard_name = "Basic Dashboard"

  chart {
    name = "CPU"
    rank = "0"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      metric              = "system.cpu.load_average.1m"
      timeseries_operator = "last"


      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }

  }

  chart {
    name = "MEMORY"
    rank = "1"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      metric              = "system.memory.usage"
      timeseries_operator = "last"


      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }

  }

  chart {
    name = "NETWORK"
    rank = "2"
    type = "timeseries"

    query {
      query_name          = "a"
      display             = "line"
      hidden              = false

      metric              = "system.network.connections"
      timeseries_operator = "last"


      group_by {
        aggregation_method = "sum"
        keys = []
      }

    }
  }
}
