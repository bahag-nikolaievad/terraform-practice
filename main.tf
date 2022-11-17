terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "bahag-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "server" {
  name          = "bahag-vpc-server"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "database" {
  name          = "bahag-vpc-database"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "database2" {
  name          = "bahag-vpc-database2"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Cloud Run
# A developer comes up to you and asks you 
# how he can deploy and manage 
# the Hello-World Docker container 
# in the GCP service “Cloud Run”. 
# Additionally, he would like 
# some Terraform example code to deploy the container.

resource "google_cloud_run_service" "cloud_run" {
  name     = "hello-world-cloud-run"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}