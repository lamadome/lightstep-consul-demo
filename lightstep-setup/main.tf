terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }
}

data "kubectl_path_documents" "lightstep" {
  pattern = "${path.module}/otel-colector/*.yaml"
  vars = {
        LIGHTSTEP_ACCESS_TOKEN = var.LIGHTSTEP_ACCESS_TOKEN
    }
}

resource "kubectl_manifest" "lightstep" {
  # count     = length(data.kubectl_path_documents.manifests.documents)
  # For some reason using the above line returns a count not known until apply
  # error, even though the files are static. This needs to be kept in sync with
  # the YAML files defined in the services/ directory.
  count     = 7
  yaml_body = element(data.kubectl_path_documents.lightstep.documents, count.index)
}
# Example: Create basic dashboard
module "lightstep_metric_dashboard" {
  source            = "./lightste_dashboard"
  project = var.lightstep_project
  lightstep_api_key = var.lightstep_api_key
  lightstep_org = var.lightstep_org
  LIGHTSTEP_ACCESS_TOKEN = var.LIGHTSTEP_ACCESS_TOKEN
}
