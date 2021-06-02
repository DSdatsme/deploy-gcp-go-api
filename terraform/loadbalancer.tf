# Bucket backend servive
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

  health_checks         = [google_compute_health_check.http-check.id]
  load_balancing_scheme = "EXTERNAL"
  backend {
    description = "backend to have application VMs"
    group       = google_compute_instance_group_manager.go-app.instance_group
  }
}


# Setup Application Loadbalancer
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project = var.gcp_default_project_id
  name    = var.loadbalancer_name

  url_map        = google_compute_url_map.url-map.self_link
  create_url_map = false
  backends = {
    default = {
      description            = null
      protocol               = "HTTP"
      port                   = 80
      port_name              = "http"
      timeout_sec            = 10
      enable_cdn             = false
      custom_request_headers = null
      security_policy        = null

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
        enable      = true
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

# URL map to above ALB
resource "google_compute_url_map" "url-map" {
  name        = var.loadbalancer_name
  description = "url mapping for website components"

  default_service = google_compute_backend_service.app-backend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allroutes"
  }

  path_matcher {
    name            = "allroutes"
    default_service = google_compute_backend_service.app-backend.self_link

    path_rule {
      paths   = ["/index.html"]
      service = google_compute_backend_bucket.static-backend-bucket.self_link
    }

    path_rule {
      paths   = ["/main.js"]
      service = google_compute_backend_bucket.static-backend-bucket.self_link
    }

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.app-backend.self_link
    }
  }
}


# use this when you are not using lb module and want to just use URL map resource
# resource "google_compute_target_http_proxy" "lb-proxy" {
#   name        = "target-proxy"
#   description = "proxy mapper"
#   url_map     = google_compute_url_map.url-map.id
# }

# This is for frontend of LB if you want to manually deploy
# resource "google_compute_global_forwarding_rule" "main-rule" {
#   name       = "main-rule"
#   target     = google_compute_target_http_proxy.lb-proxy.id
#   port_range = "80"
# }
