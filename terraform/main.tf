terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "cluster-mensal"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# VPC
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# =======================
# FRONTEND INSTANCE
# =======================
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-small"

  tags = ["ssh-access", "app-access", "frontend"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    # IP público habilitado
    access_config {}
  }
}

# =======================
# BACKEND INSTANCE
# =======================
resource "google_compute_instance" "backend_vm" {
  name         = "backend-instance"
  machine_type = "e2-small"

  tags = ["ssh-access", "backend-app"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    # Sem access_config = sem IP público
    # Apenas IP interno
  }
}

# =======================
# DATABASE INSTANCE
# =======================

resource "google_compute_instance" "db_vm" {
  name         = "postgresql-db"
  machine_type = "e2-small"
  tags         = ["db", "ssh-access"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    # Sem access_config para manter IP privado
  }
}

# =======================
# VPN INSTANCE
# =======================

resource "google_compute_instance" "vpn_host" {
  name         = "vpn-host"
  machine_type = "e2-small"
  zone         = "us-central1-c"

  tags = ["ssh-access", "vpn"]

  boot_disk {
  initialize_params {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
# =======================
# FIREWALL RULES
# =======================

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
}

resource "google_compute_firewall" "allow_frontend_app" {
  name    = "allow-frontend-app"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app-access"]
}

resource "google_compute_firewall" "allow_frontend_to_backend" {
  name    = "allow-frontend-to-backend"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [google_compute_instance.vm_instance.network_interface[0].network_ip]

  target_tags = ["backend-app"]
}

resource "google_compute_firewall" "allow_backend_to_db" {
  name    = "allow-backend-to-db"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["10.128.0.0/20"]
  target_tags   = ["db", "backend-app"]
}

resource "google_compute_firewall" "allow_openvpn" {
  name    = "allow-openvpn"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vpn"]
}

resource "google_compute_firewall" "allow_vpn_to_internal" {
  name    = "allow-vpn-to-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["ssh-access", "backend-app", "db"]
}

resource "google_compute_firewall" "allow_icmp_internal" {
  name    = "allow-icmp-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/20", "10.8.0.0/24"]
  target_tags   = ["ssh-access", "backend-app", "app-access", "vpn", "db"]
}


# =======================
# CLOUD NAT
# =======================

# 1. Cloud Router
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.vpc_network.name
  region  = "us-central1"
}

# 2. Cloud NAT
resource "google_compute_router_nat" "nat_config" {
  name                               = "nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# =======================
# OUTPUTS
# =======================

output "frontend_public_ip" {
  description = "IP público do frontend"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "frontend_internal_ip" {
  description = "IP interno do frontend"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "backend_internal_ip" {
  description = "IP interno do backend"
  value       = google_compute_instance.backend_vm.network_interface[0].network_ip
}

output "db_internal_ip" {
  description = "IP interno da VM do banco de dados"
  value       = google_compute_instance.db_vm.network_interface[0].network_ip
}
