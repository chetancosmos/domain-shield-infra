locals {
  # Only the values in var.secrets are sensitive; the keys are secret names we
  # define in code. Terraform still taints keys() as sensitive when it comes from
  # a sensitive map, so unwrap explicitly to use them in for_each.
  secret_ids = nonsensitive(toset(keys(var.secrets)))
}

resource "google_secret_manager_secret" "secret" {
  for_each  = local.secret_ids
  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "version" {
  for_each    = local.secret_ids
  secret      = google_secret_manager_secret.secret[each.value].id
  secret_data = var.secrets[each.value]
}

resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each = {
    for pair in setproduct(local.secret_ids, var.accessor_service_accounts) :
    "${pair[0]}::${pair[1]}" => {
      secret_id = pair[0]
      member    = pair[1]
    }
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.secret[each.value.secret_id].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value.member}"
}
