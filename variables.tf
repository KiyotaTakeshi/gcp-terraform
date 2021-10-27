locals {
  project         = "sandbox-330309"
  default_network = "projects/${local.project}/global/networks/default"
}

variable "region" {
  type = string
  # @see https://cloud.google.com/compute/docs/regions-zones?hl=ja#available
  # @see https://cloud.google.com/compute/docs/regions-zones/viewing-regions-zones#viewing_a_list_of_available_regions
  default = "asia-northeast1"
}


variable "zone" {
  type    = string
  default = "asia-northeast1-a"
}