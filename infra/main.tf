variable "project" {
    type=string
}

variable "region" {
    type=string
}

variable "zone" {
    type=string
}

variable "keypath" {
    type=string
}

variable "bucket-location" {
  type=string
}
variable "subnetwork-name" {
  type=string
}
variable "ip_cidr_range" {
  type=string
}
variable "secondary_1" {
  type=string
}
variable "secondary_2" {
  type=string
}
variable "ip_cidr_range_1" {
  type=string
}
variable "ip_cidr_range_2" {
  type=string
}


provider "google" {
    credentials = var.keypath 
    project = var.project
    region  = var.region
    zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket-test-tester-150998"
    prefix = "terraform/state"
  }
  required_providers {
    google= {}
  }
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}


resource "google_compute_network" "infra" {
  name  =   "infra"
  auto_create_subnetworks         = false
  mtu                             = 1460
  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

resource "google_compute_subnetwork" "custom-network" {
  name=var.subnetwork-name
  ip_cidr_range = var.ip_cidr_range
  region = var.region
  network = google_compute_network.infra.id
  private_ip_google_access = true
  secondary_ip_range{
    range_name = var.secondary_1
    ip_cidr_range = var.ip_cidr_range_1
  }
  secondary_ip_range{
    range_name = var.secondary_2
    ip_cidr_range = var.ip_cidr_range_2
  }

}

resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

# resource "google_compute_router" "custom-router" {
#   name = "custom-router"
#   region = var.region
#   network = google_compute_network.infra.id
# }

# resource "google_compute_router_nat" "nat" {
#   name = "custom-nat"
#   router = google_compute_router.custom-router.name
#   region = var.region

#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   nat_ip_allocate_option             = "MANUAL_ONLY"

#   subnetwork {
#     name                    = google_compute_subnetwork.custom-network.id
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }

#   nat_ips = [google_compute_address.nat.self_link]
# }

# resource "google_compute_address" "nat" {
#   name         = "nat"
#   address_type = "EXTERNAL"
#   network_tier = "PREMIUM"
#   depends_on = [google_project_service.compute]
# }

resource "google_container_cluster" "primary" {
  name  = "primary"
  location = var.region
  initial_node_count = 1
  remove_default_node_pool = true
  deletion_protection=false
  cluster_autoscaling {
    enabled = true
    resource_limits {
      maximum = 16
      resource_type = "cpu"
    }
    resource_limits {
      maximum = 20
      resource_type = "memory"
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
    name = "primary-nodes"
    location = var.region
    cluster = google_container_cluster.primary.id
    initial_node_count = 1

    management {
    auto_repair  = true
    auto_upgrade = true
    }
    autoscaling {
      # min_node_count = 1
      # max_node_count = 4
      total_min_node_count = 1
      total_max_node_count = 4
    }
    
    node_config {
    preemptible  = false
    machine_type = "e2-small"
    labels = {
      node = "primary",
      try  =  "this"
    }
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.kubernetes.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "secondary_nodes" {
    name = "secondary-nodes"
    location = var.region
    cluster = google_container_cluster.primary.id
    initial_node_count = 1
    management {
    auto_repair  = true
    auto_upgrade = true
    }   
    autoscaling {
      total_min_node_count = 1
      total_max_node_count = 4
    }
    node_config {
    preemptible  = true
    machine_type = "e2-small"

    labels = {
      node = "secondary"
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.kubernetes.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}