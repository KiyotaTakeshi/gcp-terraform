data "google_compute_image" "debian10" {
  family  = "debian-10"
  project = "debian-cloud"
}

resource "google_compute_disk" "default" {
  name  = "instance-1"
  type  = "pd-balanced"
  zone  = "asia-northeast1-a"
  image = data.google_compute_image.debian10.self_link
  size = 10
  # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk#physical_block_size_bytes
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "instance-1" {
  name = "instance-1"

  # @see https://cloud.google.com/compute/docs/machine-types
  #  machine_type = "e2-micro-2"
  machine_type = "e2-micro"

  # @see @see https://cloud.google.com/compute/docs/regions-zones?hl=ja#available
  zone = "asia-northeast1-a"
  tags = ["http-server", "https-server"]

  boot_disk {
    auto_delete = true
    device_name = "instance-1"

#    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#initialize_params
#    initialize_params {
#      # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image
#      image = data.google_compute_image.debian10.self_link
#      # labels = {}
#      size  = 10
#      # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#type
#      type  = "pd-balanced"
#    }

    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#mode
    mode        = "READ_WRITE"
    source      = google_compute_disk.default.self_link
  }
  can_ip_forward      = false
  deletion_protection = false

  #  # Local SSD disk
  #  scratch_disk {
  #    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#interface
  #    interface = "SCSI"
  #  }

  network_interface {
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#network
    network    = "default"
    # private IP
    network_ip = "10.146.0.2"
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#subnetwork
    subnetwork = "default"

    access_config {
      # Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "244021078925-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}