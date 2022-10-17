provider "google" {
  project     = var.project
  credentials = secrets.GOOGLE_CREDENTIALS
  region      = var.region
  zone        = var.zone
}