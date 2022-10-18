provider "google" {
  project = var.project
  #credentials = file("/Users/nikolaievad/Documents/Bauhaus/terraform-practice/doit-sandbox-20220613-kbwhxs-87ba948b979a.json")
  region = var.region
  zone   = var.zone
}

terraform {
  backend "gcs" {
    bucket = "terraform-state-dariia"
    prefix = "terraform/state"
  }
}