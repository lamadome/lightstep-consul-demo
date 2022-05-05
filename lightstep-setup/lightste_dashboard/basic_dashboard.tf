terraform {
  required_providers {
    lightstep = {
      source = "lightstep/lightstep"
      version = "1.60.3"
    }
  }
}

provider "lightstep" {
  api_key         = "eyJhbGciOiJIUzI1NiIsImtpZCI6IjIwMTktMDMtMDEiLCJ0eXAiOiJKV1QifQ.eyJzY3AiOnsicm9sZSI6ImU1MTI5NmJkLTFjYjktMTFlOC05M2Y1LTQyMDEwYWYwMGFkNiJ9LCJ2ZXIiOjEsImRlYnVnIjp7Im9yZyI6Imhhc2hpY29ycC0xN2YxNzk1NSIsInJvbGUiOiJPcmdhbml6YXRpb24gQWRtaW4ifSwiYXVkIjoiYXBwLmxpZ2h0c3RlcC5jb20iLCJleHAiOjE2ODI3ODMzNjYsImp0aSI6InlmaGZpc2dkbmdlZXZ6bXd3eXI3dWV4MzV0Y2toYXJwZGl1YnR0amJ1NzI2NGFnbSIsImlhdCI6MTY1MTI0NzM2NiwiaXNzIjoibGlnaHRzdGVwLmNvbSIsInN1YiI6Iml6cXJuY2RnNGxvdDRhZ2xiY3lsbXlubmtpemdtbHozbHNpNmgyYWZydjVnMmVhcyJ9.uJgPq11I7l_cKdPTFZ5uzojvnotz5bOykiXW8CxKhx4"
  organization    = "hashicorp-17f17955"
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

  chart {
    name = "Public API Queries"
    rank = "3"
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
    rank = "4"
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

}
