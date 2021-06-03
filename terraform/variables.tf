variable "gcp_default_project_id" {
  type    = string
  default = "gcp-project-id-<xyz>"
}

variable "default_gcp_region" {
  type    = string
  default = "asia-south1"
}

variable "default_gcp_zone" {
  type    = string
  default = "asia-south1-b"
}

variable "bucket_name" {
  type    = string
  default = "dsdatsme-static"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "sql_password" {
  type      = string
  sensitive = true
  default   = "sudopasswd"
}

variable "loadbalancer_name" {
  type    = string
  default = "app-lb"
}

variable "ubuntu_image_name" {
  type    = string
  default = "consul-ubuntu18-<id>"
}

variable "consul_cluster_join_tag" {
  type    = string
  default = "join-consul"
}
