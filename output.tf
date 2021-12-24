output "compute_instance_name" {
  value = google_compute_instance.instance_1.name
}

output "sql_database_instance_id" {
  value = google_sql_database_instance.sample.id
}

output "sql_database_instance_private_ip" {
  value = google_sql_database_instance.sample.private_ip_address
}

output "sql_database_instance_connection_name" {
  value = google_sql_database_instance.sample.connection_name
}

