/*
This Terraform code creates a Google Cloud infrastructure for a latency test. 
It enables the required APIs, creates two service accounts, a cloud function, 
a cloud scheduler job, a BigQuery dataset and a table in BigQuery.
The cloud function "latency_test" takes an HTTP GET request 
and logs the latency in accessing the list of hosts defined in the environment variable HOST_LIST. 
The result is stored in the BigQuery table "latency_test". 
The cloud scheduler job triggers the cloud function every 1 minute. 
The uniform_bucket_level_access for the function storage bucket is set to true, 
which means that all objects in the bucket are automatically encrypted. 
The source code for the function is stored as a zip archive in the function storage bucket.
*/

# enable API for the project
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "bigquery.googleapis.com"
  ])
  project = var.project
  service = each.key
}

# Google Service Account for the scheduler
resource "google_service_account" "scheduler" {
  account_id   = "cloudscheduler-latency-test"
  display_name = "Service Account for running latency-test schedule"
}

# Google Service Account for the function
resource "google_service_account" "function_runner" {
  account_id   = "function-latency-test"
  display_name = "Service Account for running latency-test function"
}

# Google IAM Member
resource "google_project_iam_member" "scheduler_invoke_function" {
  project = var.project
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler.email}"
}

# Google Cloud Functions
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "/tmp/latency_test_function.zip"
}

resource "google_storage_bucket" "function_bucket" {
  name                        = "${var.project}-function-latency_test"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"
  name         = "src-${data.archive_file.source.output_md5}.zip"
  bucket       = google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "latency_test_function" {
  name                  = "latency_test"
  runtime               = "python310"
  available_memory_mb   = 128
  service_account_email = google_service_account.function_runner.email

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name

  entry_point  = "latency_test"
  trigger_http = true
  environment_variables = {
    HOST_LIST = "[{ 'www.bauhaus.info' : 'BAUHAUS home page' }, { 'www.google.com' : 'GOOGLE' }]"
  }
}

# Google Cloud Scheduler Job
resource "google_cloud_scheduler_job" "scheduler_job" {
  name     = "function_caller_latency_test"
  schedule = "1 * * * *"
  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.latency_test_function.https_trigger_url
    oidc_token {
      service_account_email = google_service_account.scheduler.email
    }
  }
}

# BigQuery
resource "google_bigquery_dataset" "latency_test_dataset" {
  dataset_id                  = "latency_test_dataset"
  description                 = "Latency Test Dataset"
  location                    = var.region
  default_table_expiration_ms = 3600000
}

resource "google_bigquery_table" "latency_test_table" {
  dataset_id = google_bigquery_dataset.latency_test_dataset.dataset_id
  table_id   = "latency_test"

  schema = <<EOF
  [
    {
      "name": "date",
      "type": "DATETIME"
    },
    {
      "name": "host_name",
      "type": "STRING"
    },
    {
      "name": "ip_address",
      "type": "STRING"
    },
    {
      "name": "description",
      "type": "STRING"
    },
    {
      "name": "result",
      "type": "STRING"
    },
    {
      "name": "latency_ms",
      "type": "FLOAT"
    }
  ]
  EOF
}