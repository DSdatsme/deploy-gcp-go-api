module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.gcp_default_project_id
  network_name = "dev-go-network"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "app-subnet"
      subnet_ip             = "10.0.0.0/24"
      subnet_region         = var.default_gcp_region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "This subnet is for deploying applications"
    }
  ]

  routes = [
        # IGW not needed
    ]
}


resource "google_compute_global_address" "private-ip-db" {
  name          = "private-ip-db"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_name
}

resource "google_service_networking_connection" "peer-db" {
  network                 = module.vpc.network_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-ip-db.name]
}
