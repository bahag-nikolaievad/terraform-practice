terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name = "bahag-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "server" {
    name = "bahag-vpc-server"
    ip_cidr_range = "10.0.0.0/24"
    region = var.region
    network = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "database" {
    name = "bahag-vpc-database"
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "database2" {
    name = "bahag-vpc-database2"
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.vpc_network.id
}