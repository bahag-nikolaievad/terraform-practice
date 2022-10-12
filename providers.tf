provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  # backend "gcs" {
  #   bucket = "gcpprojectid-tfstate"
  #   prefix = "terraform/state"
  # }
}