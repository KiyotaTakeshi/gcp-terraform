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
  tags = ["http-server", "https-server", "spring"]

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

#  service_account {
#    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#    email  = "244021078925-compute@developer.gserviceaccount.com"
#    scopes = [
#      "https://www.googleapis.com/auth/devstorage.read_only",
#      "https://www.googleapis.com/auth/logging.write",
#      "https://www.googleapis.com/auth/monitoring.write",
#      "https://www.googleapis.com/auth/service.management.readonly",
#      "https://www.googleapis.com/auth/servicecontrol",
#      "https://www.googleapis.com/auth/trace.append"
#    ]
#  }
}

resource "google_sql_database_instance" "sample" {
  name = "sample-428d0617-6ed5-42d2-aa26-216bcc6b73a3"
  database_version = "POSTGRES_11"
  region           = var.region
  # for development
  deletion_protection = false

  # replica_configuration {}
  settings {
    tier = "db-custom-1-3840"
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#availability_type
    availability_type = "ZONAL"
    backup_configuration {
      enabled = true
      # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#start_time
      start_time = "16:00"
      location = "us"
      point_in_time_recovery_enabled = false
      binary_log_enabled = false
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit = "COUNT"
      }
    }
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#disk_autoresize
    disk_autoresize = true
    disk_size = 10
    disk_type = "PD_SSD"
    ip_configuration {
      # not attach public ip
      # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ipv4_enabled
      ipv4_enabled = false
      private_network = "projects/sandbox-329805/global/networks/default"
#      authorized_networks {
#        value = ""
#      }
    }
    location_preference {
      zone = "asia-northeast1-a"
    }
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#day
    maintenance_window {
      day = 5
      # The maintenance window is specified in UTC time
      hour = 17 # 26(2AM)
    }
  }
}
