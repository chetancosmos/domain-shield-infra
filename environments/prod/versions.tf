terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Bootstrap this bucket by hand before first `terraform init`:
  #   gsutil mb -p <project_id> -l <region> gs://<project_id>-tfstate
  #   gsutil versioning set on gs://<project_id>-tfstate
  backend "gcs" {
    bucket = "project-e81a57d7-c451-4010-8d6-tfstate"
    prefix = "domainshield/prod"
  }
}
