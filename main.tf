data "google_compute_image" "debian10" {
  family  = "debian-10"
  project = "debian-cloud"
}

resource "google_compute_disk" "default" {
  name  = "instance-1"
  type  = "pd-balanced"
  zone  = var.zone
  image = data.google_compute_image.debian10.self_link
  size  = 10
  # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk#physical_block_size_bytes
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "instance_1" {

  depends_on = [google_compute_disk.default]

  name = "instance-1"

  # @see https://cloud.google.com/compute/docs/machine-types
  machine_type = "e2-micro"

  # @see https://cloud.google.com/compute/docs/regions-zones?hl=ja#available
  zone = var.zone
  tags = ["http-server", "https-server", "spring"]

  boot_disk {
    auto_delete = false
    device_name = google_compute_disk.default.name

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
    mode   = "READ_WRITE"
    source = google_compute_disk.default.self_link
  }
  can_ip_forward      = false
  deletion_protection = false

  #  # Local SSD disk
  #  scratch_disk {
  #    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#interface
  #    interface = "SCSI"
  #  }

  metadata_startup_script = file("./setup.sh")

  network_interface {
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#network
    network = "default"
    # private IP
    network_ip = "10.146.0.2"
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#subnetwork
    subnetwork = "default"

    access_config {
      # Ephemeral public IP
    }
  }
}

resource "google_compute_firewall" "spring" {
  name    = "allow-spring"
  network = local.default_network

  allow {
    protocol = "tcp"
    ports    = ["8080", "8081"]
  }

  # source_tags = [""]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network" "private_network" {
  provider = google-beta
  name     = "private-network"
}
resource "google_compute_global_address" "private_ip_block" {
  provider      = google-beta
  name          = "private-ip-block"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = local.default_network
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = local.default_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_sql_database_instance" "sample" {

  depends_on       = [google_service_networking_connection.private_vpc_connection]
  name             = "sample-${random_id.db_name_suffix.hex}"
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
      start_time                     = "16:00"
      location                       = "us"
      point_in_time_recovery_enabled = false
      binary_log_enabled             = false
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#disk_autoresize
    disk_autoresize = true
    disk_size       = 10
    disk_type       = "PD_SSD"

    ip_configuration {
      # not attach public ip
      # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ipv4_enabled
      ipv4_enabled    = false
      private_network = local.default_network
      #      authorized_networks {
      #        value = ""
      #      }
    }
    location_preference {
      zone = var.zone
    }
    # @see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#day
    maintenance_window {
      day = 5
      # The maintenance window is specified in UTC time
      hour = 17 # 26(2AM)
    }
  }
}
