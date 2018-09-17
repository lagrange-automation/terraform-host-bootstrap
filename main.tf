// Bootstrap a GCP environment with a host project and remote state

locals {
  prefix     = "${lower(var.name)}"
  project_id = "${local.prefix}-host-${random_id.random_project_id_suffix.hex}"

  default_services = [
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "oslogin.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com"
  ]

  bootstrap_roles = [
    // Permission to view organization IAM policy. This is needed when the bootstrap
    // account is being used to manage the bootstrap module, because it needs to
    // enumerate the organization policy to see that it has the following roles.
    "roles/browser",

    // Permissions required for the bootstrap service account to manage itself.
    // This is not needed if the bootstrap service account will not be used to run
    // the bootstrap configuration itself.
    "roles/resourcemanager.organizationAdmin",

    "roles/resourcemanager.organizationViewer",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectIamAdmin",

    // Normally grant this
    "roles/resourcemanager.folderViewer",
    // But this is used so that the user can stand up folders
    "roles/resourcemanager.folderAdmin",

    "roles/appengine.appViewer",
    "roles/billing.user",
    "roles/compute.xpnAdmin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin"
  ]

  bootstrap_project_roles = [
    "roles/storage.admin"
  ]

  sa_credentials_dir    = "~/.config/gcloud/service-accounts"
  bootstrap_credentials = "${local.sa_credentials_dir}/${google_service_account.main.email}.json"
  bootstrap_sa_fmt      = "serviceAccount:${google_service_account.main.email}"
}

resource "google_folder" "main" {
  display_name = "${var.name}"
  parent       = "organizations/${var.organization_id}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

resource "google_project" "main" {
  project_id      = "${local.project_id}"
  name            = "${var.name} Host"
  folder_id       = "${google_folder.main.name}"
  billing_account = "${var.billing_account}"
}

resource "google_project_services" "main" {
  project  = "${google_project.main.project_id}"
  services = "${local.default_services}"
}

resource "random_id" "tf_state_suffix" {
  byte_length = 2
}

resource "google_storage_bucket" "terraform-state" {
  name       = "terraform-state-${random_id.tf_state_suffix.hex}"
  project    = "${google_project.main.project_id}"
  location   = "US"
  depends_on = ["google_project_services.main"]
}

resource "random_id" "bootstrap_sa_suffix" {
  byte_length = 2
}

resource "google_service_account" "main" {
  project = "${google_project.main.project_id}"
  display_name = "${var.name} Bootstrap service account"
  account_id = "${local.prefix}-bootstrap-${random_id.bootstrap_sa_suffix.hex}"
}

resource "google_service_account_key" "main" {
  service_account_id = "${google_service_account.main.name}"

  provisioner "local-exec" {
    command = "mkdir -p ${local.sa_credentials_dir}"
  }

  provisioner "local-exec" {
    command = "base64 --decode <(echo $KEY_B64) > ${local.bootstrap_credentials}"

    interpreter = ["bash", "-c"]

    environment {
      KEY_B64 = "${google_service_account_key.main.private_key}"
    }
  }
}

resource "google_organization_iam_member" "bootstrap_roles" {
  count = "${length(local.bootstrap_roles)}"
  org_id = "${var.organization_id}"
  role = "${element(local.bootstrap_roles, count.index)}"
  member = "${local.bootstrap_sa_fmt}"
}

resource "google_project_iam_member" "bootstrap_roles" {
  count   = "${length(local.bootstrap_project_roles)}"
  project = "${google_project.main.project_id}"
  role    = "${element(local.bootstrap_project_roles, count.index)}"
  member  = "${local.bootstrap_sa_fmt}"
}
