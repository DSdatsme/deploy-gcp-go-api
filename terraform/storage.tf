
# GCS to store static content
resource "google_storage_bucket" "static-content" {
  name          = var.bucket_name
  location      = var.default_gcp_region
  force_destroy = true

  labels = {
    purpose     = "hosting"
    deployed-by = "terraform"
    env         = "dev"
  }
}

# upload main.js to GCS
resource "google_storage_bucket_object" "main-js" {
  name   = "main.js"
  source = "../public/main.js"
  bucket = google_storage_bucket.static-content.name
}

# upload index.html to GCS
resource "google_storage_bucket_object" "index-html" {
  name   = "index.html"
  source = "../public/index.html"
  bucket = google_storage_bucket.static-content.name
}


data "google_iam_policy" "public-view" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allUsers",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.static-content.name
  policy_data = data.google_iam_policy.public-view.policy_data
}
