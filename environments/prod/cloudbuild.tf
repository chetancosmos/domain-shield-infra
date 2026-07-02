# One-time manual step before this applies cleanly: install/authorize the
# "Google Cloud Build" GitHub App on the repo (console: Cloud Build > Triggers >
# Connect Repository). Terraform can't do that OAuth handshake for you.
resource "google_cloudbuild_trigger" "backend_deploy" {
  project     = var.project_id
  name        = "domainshield-backend-deploy"
  description = "Build api+worker images and deploy to Cloud Run on push to main"

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = var.github_deploy_branch
    }
  }

  # domain-shield-backend is its own repo (not a monorepo subfolder), so both
  # paths are relative to that repo's root.
  filename = "cloudbuild.yaml"

  depends_on = [google_project_service.apis]
}
