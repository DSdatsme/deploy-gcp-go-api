resource "google_compute_firewall" "consul-firewall" {
  name        = "access-consul-firewall"
  description = "consul port access"
  network     = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "8500"] # WARNING: expose consul publically
  }

  target_tags = ["expose-consul"]
}
module "consul_cluster" {
  # Use version v0.0.1 of the consul-cluster module
  source = "github.com/hashicorp/terraform-google-consul//modules/consul-cluster?ref=v0.5.0"

  gcp_project_id = var.gcp_default_project_id
  gcp_region     = var.default_gcp_region

  network_name               = module.vpc.network_name
  subnetwork_name            = module.vpc.subnets_names[0]
  custom_tags                = ["expose-consul", var.consul_cluster_join_tag]
  cluster_name               = "consul-server"
  cluster_description        = "Service Discovery Cluster"
  machine_type               = "f1-micro"
  source_image               = var.ubuntu_image_name
  cluster_size               = 1
  assign_public_ip_addresses = true

  # Add this tag to each node in the cluster for auto discovery
  cluster_tag_name = var.consul_cluster_join_tag

  startup_script = <<-EOF
              #!/bin/bash
              /opt/consul/bin/run-consul --server --cluster-tag-name ${var.consul_cluster_join_tag}
              EOF

  # Ensure the Consul node correctly leaves the cluster when the instance restarts or terminates.
  shutdown_script = <<-EOF
              #!/bin/bash
              /opt/consul/bin/consul leave
              EOF
}
