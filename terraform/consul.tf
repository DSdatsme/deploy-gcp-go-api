module "consul" {
  source  = "hashicorp/consul/google"
  version = "0.5.0"
  # insert the 10 required variables here
  gcp_project_id                 = var.gcp_default_project_id
  gcp_region                     = var.default_gcp_region
  
  consul_server_cluster_name     = "consul-server"  
  consul_server_cluster_tag_name = "cluster-tag"
  consul_server_source_image     = "consul-ubuntu18-60b69add-90fc-e6f1-8d14-cdbd65227996"
  consul_server_cluster_size     = 1

  consul_client_cluster_name     = "go-application"
  consul_client_cluster_tag_name = "consul-go-client"
  consul_client_source_image     = "consul-ubuntu18-60b69add-90fc-e6f1-8d14-cdbd65227996"
  consul_client_cluster_size     = 0
}
