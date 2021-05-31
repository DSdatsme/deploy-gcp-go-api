# bucket backend servive
resource "google_compute_backend_bucket" "static-backend-bucket" {
  name        = "static-asset-backend-bucket"
  bucket_name = google_storage_bucket.static-content.name
  enable_cdn  = true
}


# VM Backend service
resource "google_compute_backend_service" "app-backend" {
  name        = "app-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.http-check.id]
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_url_map" "bucket-map" {
  name        = "urlmap"
  description = "a description"

  default_service = google_compute_backend_bucket.static-backend-bucket.id



  path_matcher {
    name            = "static"
    default_service = google_compute_backend_bucket.static-backend-bucket.id

    path_rule {
      paths   = ["/index.html"]
      service = google_compute_backend_bucket.static-backend-bucket.id
    }

    path_rule {
      paths   = ["/main.js"]
      service = google_compute_backend_bucket.static-backend-bucket.id
    }

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.app-backend.id
    }
  }


}


module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 4.4"

  project = var.gcp_default_project_id
  name              = "group-http-lb"
  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = false
      custom_request_headers          = null
      security_policy                 = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/api/status"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = google_compute_instance_group_manager.go-app.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}
