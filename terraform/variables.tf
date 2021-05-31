variable "gcp_default_project_id" {
  type    = string
  default = "playground-s-11-39f46c13"
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
  default = "dsdatsme-3"
}

variable "github_token" {
  type      = string
  sensitive = true
}
