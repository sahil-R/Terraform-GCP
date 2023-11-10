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

provider "google" {
    credentials = var.keypath 
    project = var.project
    region  = var.region
    zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket = "terraform-state-test-tester-150998"
    prefix = "terraform/state"
  }
  required_providers {
    google= {}
  }
}


resource "google_compute_network" "infra" {
  name  =   "vpc-network"
}

