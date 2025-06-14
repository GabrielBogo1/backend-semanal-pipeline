terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }

  required_version = ">= 1.3.0"
}

provider "google" {
  project = "cluster-mensal-462916"
  region  = "us-central1"
  credentials = file("account.json")
}

resource "google_container_cluster" "primary" {
  name     = "gke-stage"
  location = "us-central1-a"  # Zona exata para criar um cluster ZONAL

  remove_default_node_pool = true
  initial_node_count       = 1

  enable_legacy_abac = true

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
