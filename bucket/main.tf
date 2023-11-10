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

resource "google_storage_bucket" "terraform-state" {
  name  = "terraform-state-bucket"
  location = var.bucket-location
}