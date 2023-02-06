provider "google" {
  project = var.project
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "terraform-state-dariia"
    prefix = "terraform/state"
  }
  required_version = "~> 1.3.0"
  required_providers {
    google = {}
  }
}
