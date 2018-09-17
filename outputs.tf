output "host_folder" {
  description = "The host folder"
  value       = "${google_folder.main.name}"
}

output "host_project_id" {
  description = "The host project ID"
  value       = "${google_project.main.project_id}"
}

output "terraform_state_bucket" {
  description = "The Terraform state bucket"
  value = "${google_storage_bucket.terraform-state.name}"
}

output "host_bootstrap_account_id" {
  description = "The host bootstrapping account ID"
  value = "${google_service_account.main.account_id}"
}

output "host_bootstrap_account_email" {
  description = "The host bootstrapping account email"
  value = "${google_service_account.main.email}"
}

output "host_bootstrap_credentials_path" {
  description = "The bootstrap service account credentials"
  value = "${local.bootstrap_credentials}"
}

output "host_bootstrap_credentials_name" {
  description = "The bootstrap service account credentials"
  value = "${google_service_account_key.main.name}"
}
