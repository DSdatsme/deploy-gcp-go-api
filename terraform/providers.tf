terraform {
  required_version = "0.14.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.69.0"
    }
  }
}

provider "google" {
  project = var.gcp_default_project_id
  region  = var.default_gcp_region
  zone    = var.default_gcp_zone
}
