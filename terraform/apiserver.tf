#################################################################################
# NOTE:
#   This file is depricated in favour of `managed_instance_group.tf`
#   Use this if you want to do a custom deploy of API server and test things
#################################################################################


# VM for Go API server [TEST]
# resource "google_compute_instance" "api-server" {
#   name         = "go-api-server"
#   machine_type = "f1-micro"
#   zone         = var.default_gcp_zone

#   tags = ["go-server"]

#   boot_disk {
#     auto_delete = true
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-1804-lts"
#     }
#   }

#   network_interface {
#     network    = module.vpc.network_name
#     subnetwork = module.vpc.subnets_names[0] # selecting the first subnet
#     access_config {
#       # This creates ephemeral pub IP
#     }
#   }

#   labels = {
#     purpose     = "hosting"
#     deployed-by = "terraform"
#     env         = "dev"
#   }

#   metadata_startup_script = data.template_file.custom-startup-script.rendered

# }
