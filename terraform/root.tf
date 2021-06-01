# TODO: add backend storage for state file

resource "google_project_service" "enable-networking" {
  project = var.gcp_default_project_id
  service = "servicenetworking.googleapis.com"
}
