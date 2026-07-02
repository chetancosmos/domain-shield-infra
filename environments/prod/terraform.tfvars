project_id = "project-e81a57d7-c451-4010-8d6"
region     = "asia-south1"

github_owner     = "chetancosmos"
github_repo_name = "domain-shield-backend"

# Backend work is currently happening on feature-gcp, not main. Switch this
# back to "^main$" once that branch is merged.
github_deploy_branch = "^feature-gcp$"

# jwt_secret is intentionally NOT set here (sensitive) - pass it via
# -var-file=secrets.auto.tfvars (gitignored) or TF_VAR_jwt_secret env var.
# sendgrid_api_key same story; defaults to "" (SendGrid disabled) until set.
