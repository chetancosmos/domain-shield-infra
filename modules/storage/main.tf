resource "google_storage_bucket" "screenshots" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  dynamic "lifecycle_rule" {
    for_each = var.screenshot_retention_days > 0 ? [1] : []
    content {
      condition {
        age = var.screenshot_retention_days
      }
      action {
        type = "Delete"
      }
    }
  }
}

resource "google_storage_bucket_iam_member" "readers" {
  for_each = toset(var.reader_service_accounts)
  bucket   = google_storage_bucket.screenshots.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${each.value}"
}

resource "google_storage_bucket_iam_member" "writers" {
  for_each = toset(var.writer_service_accounts)
  bucket   = google_storage_bucket.screenshots.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${each.value}"
}

# Lets the reader SA (api service) mint v4 signed URLs without a downloaded key file.
resource "google_service_account_iam_member" "sign_blob" {
  for_each           = toset(var.reader_service_accounts)
  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${each.value}"
}
