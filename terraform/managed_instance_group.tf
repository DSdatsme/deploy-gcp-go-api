resource "google_compute_instance_template" "go-app-template" {
  name        = "go-appserver-template"
  description = "This template is used to create app server instances."

  tags = ["go-server"]

  labels = {
    purpose     = "hosting"
    deployed-by = "terraform"
    env         = "dev"
  }

  instance_description = "instances hosting go app"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "consul-ubuntu18-60b69add-90fc-e6f1-8d14-cdbd65227996"
    auto_delete  = true
    boot         = true
    // backup the disk every day
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0] # selecting the first subnet
    access_config {
      # This creates ephemeral pub IP
    }
  }

  metadata_startup_script = data.template_file.custom-startup-script.rendered

}

resource "google_compute_health_check" "http-check" {
  name                = "http-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    # port_name          = "http"
    port_specification = "USE_FIXED_PORT"
    request_path       = "/api/status"
    port = 80
  }
}

resource "google_compute_instance_group_manager" "go-app" {
  name = "appserver-igm"

  base_instance_name = "go-api-server"
  zone               = var.default_gcp_zone

  version {
    instance_template = google_compute_instance_template.go-app-template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-check.id
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "api-autoscaler" {
  provider = google-beta

  name   = "api-autoscaler"
  zone   = var.default_gcp_zone
  project = var.gcp_default_project_id
  target = google_compute_instance_group_manager.go-app.id

  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}
