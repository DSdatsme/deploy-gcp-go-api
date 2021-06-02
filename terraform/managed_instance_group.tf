# startup script for configuring database IP
data "template_file" "custom-startup-script" {
  template = file("./setup_deployer.sh.tpl")

  vars = {
    database_server_ip      = google_sql_database_instance.database-server.private_ip_address
    database_password       = var.sql_password
    github_token            = var.github_token
    consul_cluster_join_tag = var.consul_cluster_join_tag
  }
}

# firewall to access Go API server
# Use this to debug API server issues (SSH and HTTP open to world)
resource "google_compute_firewall" "go-server-firewall" {
  name        = "access-go-server-firewall"
  description = "http port access"
  network     = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"] # WARNING: SSH port is open to world
  }

  target_tags = ["go-server"]
}

resource "google_compute_firewall" "consul-client-firewall" {
  name        = "consul-client"
  description = "http port access"
  network     = module.vpc.network_name

  allow {
    protocol = "udp"
    ports    = ["8301", "8302", "8600"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8300", "8400", "8301", "8302", "8500", "8600"]
  }

  source_tags = [var.consul_cluster_join_tag] # note the tag here, this will allow connection to consul
  target_tags = [var.consul_cluster_join_tag]
}

resource "google_compute_instance_template" "go-app-template" {
  name_prefix = "go-appserver-template-"
  description = "This template is used to create app server instances."

  tags = ["go-server", var.consul_cluster_join_tag]

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


  disk {
    source_image = var.ubuntu_image_name
    auto_delete  = true
    boot         = true
    // backup the disk every day
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0] # NOTE: selecting the first subnet
    access_config {
      # This creates ephemeral pub IP
    }
  }

  metadata_startup_script = data.template_file.custom-startup-script.rendered

  metadata = {
    shutdown-script = "systemctl stop consul.service"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/userinfo.email",
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "http-check" {
  name                = "http-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {

    port_specification = "USE_FIXED_PORT"
    request_path       = "/api/status"
    port               = 80
  }
}

resource "google_compute_instance_group_manager" "go-app" {
  name = "appserver-mig"

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

  name    = "api-autoscaler"
  zone    = var.default_gcp_zone
  project = var.gcp_default_project_id
  target  = google_compute_instance_group_manager.go-app.id

  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}
