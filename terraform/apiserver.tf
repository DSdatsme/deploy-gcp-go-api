# firewall to access Go API server
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

# startup script for configuring database IP
data "template_file" "custom-startup-script" {
  template = file("./setup_deployer.sh.tpl")

  vars = {
    database_server_ip = google_sql_database_instance.database-server.private_ip_address
    github_token       = var.github_token
  }
}

# VM for Go API server
resource "google_compute_instance" "api-server" {
  name         = "go-api-server"
  machine_type = "f1-micro"
  zone         = var.default_gcp_zone

  tags = ["go-server"]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0] # selecting the first subnet
    access_config {
      # This creates ephemeral pub IP
    }
  }

  labels = {
    purpose     = "hosting"
    deployed-by = "terraform"
    env         = "dev"
  }

  metadata_startup_script = data.template_file.custom-startup-script.rendered

  lifecycle {
    create_before_destroy = true
  }

}
