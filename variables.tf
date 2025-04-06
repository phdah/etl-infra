variable "namespaces" {
  description = "Path to namespaces yaml"
  type        = string
}

variable "argocd" {
  description = "Path to ArgoCD yaml"
  type        = string
}

variable "applications" {
  description = "Path to applications yaml"
  type        = string
}
