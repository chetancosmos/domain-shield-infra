output "bucket_name" {
  value = google_storage_bucket.screenshots.name
}

output "bucket_url" {
  value = google_storage_bucket.screenshots.url
}
