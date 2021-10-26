terraform {
  # @see https://www.terraform.io/docs/language/settings/index.html#specifying-a-required-terraform-version
  # @see https://www.terraform.io/docs/language/expressions/version-constraints.html#gt--1
  required_version = "~> 1.0.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.89.0"
    }
  }

  backend "gcs" {
    # you need to create bucket in advance
    bucket  = "kiyotatakeshi-terraform-state"
    prefix = "dev"
  }
}

provider "google" {
  project     = local.project
  region      = var.region
}