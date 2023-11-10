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


resource "google_compute_network" "infra" {
  name  =   "vpc-network"
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
    ip_cidr_range = var.ip_cidr_range_1
  }

}

