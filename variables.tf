locals {
  project = "sandbox-329805"
}

variable "region" {
  type = string
  # @see https://cloud.google.com/compute/docs/regions-zones?hl=ja#available
  # @see https://cloud.google.com/compute/docs/regions-zones/viewing-regions-zones#viewing_a_list_of_available_regions
  default = "asia-northeast1"
}
