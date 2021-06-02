variable "gcp_default_project_id" {
  type    = string
  default = "playground-s-11-d7d433da"
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
  default = "dsdatsme-4"
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
  default = "consul-ubuntu18-<full-name>"
}

variable "consul_cluster_join_tag" {
  type    = string
  default = "join-consul"
}
