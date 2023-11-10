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

provider "google" {
    credentials = var.keypath 
    project = var.project
    region  = var.region
    zone    = var.zone
}

