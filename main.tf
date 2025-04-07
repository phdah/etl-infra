terraform {
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "minikube" {
  kubernetes_version = "v1.30.0"
}

resource "minikube_cluster" "docker" {
  driver       = "docker"
  cluster_name = "terraform-provider-minikube-acc-docker"
  addons = [
    "default-storageclass",
    "storage-provisioner"
  ]
}

provider "kubernetes" {
  host = minikube_cluster.docker.host

  client_certificate     = minikube_cluster.docker.client_certificate
  client_key             = minikube_cluster.docker.client_key
  cluster_ca_certificate = minikube_cluster.docker.cluster_ca_certificate
}

# Create the namespaces
data "kubectl_file_documents" "argocd_namespace" {
  content = file(var.namespaces)
}

# Create all namespaces specified
resource "kubectl_manifest" "argocd_namespace" {
  count     = length(data.kubectl_file_documents.argocd_namespace.documents)
  yaml_body = element(data.kubectl_file_documents.argocd_namespace.documents, count.index)
}

# ------ #
# ArgoCD #
# ------ #
# Deploy Argo CD from the official install manifest
data "kubectl_file_documents" "argocd_install" {
  content = file(var.argocd)
}

resource "kubectl_manifest" "argocd_install" {
  depends_on         = [kubectl_manifest.argocd_namespace]
  count              = length(data.kubectl_file_documents.argocd_install.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd_install.documents, count.index)
  override_namespace = "argocd"
}

# Deploy applications in ArgoCD
data "kubectl_file_documents" "argocd_application" {
  content = file(var.applications)
}

resource "kubectl_manifest" "argocd_application_install" {
  depends_on = [kubectl_manifest.argocd_install]
  count      = length(data.kubectl_file_documents.argocd_application.documents)
  yaml_body  = element(data.kubectl_file_documents.argocd_application.documents, count.index)
}

# Monitoring
data "kubectl_file_documents" "argocd_components" {
  content = file(var.components)
}

resource "kubectl_manifest" "components_install" {
  depends_on = [kubectl_manifest.argocd_install]
  count      = length(data.kubectl_file_documents.argocd_components.documents)
  yaml_body  = element(data.kubectl_file_documents.argocd_components.documents, count.index)
}

