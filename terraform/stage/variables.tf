variable "project_id" {
  description = "cluster-mensal-462916"
  type = string
}

variable "region" {
  description = "us-central1"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "stage"
  type        = string
}

variable "cluster_name" {
  description = "gke-stage"
  type        = string
}
