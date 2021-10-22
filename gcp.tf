provider "google" {
  project     = local.project
  region      = var.region
  credentials = file("~/Downloads/terraform-sandbox.json")
}