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

resource "google_storage_bucket" "terraform-state-test-tester-150998" {
  name  = "terraform-state-bucket-test-tester-150998"
  location = var.bucket-location
}



output "url" {
    value   = google_storage_bucket.terraform-state-test-tester-150998.url 
}

output "id" {
    value   = google_storage_bucket.terraform-state-test-tester-150998.id 
}

output "public-access-prevention" {
    value   = google_storage_bucket.terraform-state-test-tester-150998.public_access_prevention 
}