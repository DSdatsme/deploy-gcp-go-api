# TODO: add backend storage for state file

# Enable API if not already enabled before creating VPC
resource "google_project_service" "enable-networking" {
  project = var.gcp_default_project_id
  service = "servicenetworking.googleapis.com"
}
