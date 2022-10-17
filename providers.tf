provider "google" {
  project = var.project
  # credentials = file("/Users/nikolaievad/Downloads/doit-sandbox-20220613-kbwhxs-87ba948b979a.json")
  region  = var.region
  zone    = var.zone
}

terraform {
  # backend "gcs" {
  #   bucket = "gcpprojectid-tfstate"
  #   prefix = "terraform/state"
  # }
}