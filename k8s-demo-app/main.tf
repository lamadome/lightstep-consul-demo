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
data "kubectl_path_documents" "manifests" {
  pattern = "${path.module}/services/*.yaml"
  vars = {
        ingress-gw-name = var.ingress-gw-name
        ingress-gw-port = var.ingress-gw-port
    }
}

# data "kubectl_path_documents" "lightstep" {
#   pattern = "${path.module}/lightstep/*.yaml"
# }

resource "kubectl_manifest" "applications" {
  # count     = length(data.kubectl_path_documents.manifests.documents)
  # For some reason using the above line returns a count not known until apply
  # error, even though the files are static. This needs to be kept in sync with
  # the YAML files defined in the services/ directory.
  count     = 33
  yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
}

# data "kubernetes_service" "ingress" {
#   metadata {
#     name = var.ingress-gw-name
#   }

#   depends_on = [kubectl_manifest.applications]
# }
