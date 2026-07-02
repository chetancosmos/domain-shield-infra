project_id = "project-e81a57d7-c451-4010-8d6"
region     = "asia-south1"

# TODO: fill in once the GitHub repo is created (pending `gh auth login`).
github_owner     = "REPLACE_ME"
github_repo_name = "REPLACE_ME"

# jwt_secret is intentionally NOT set here (sensitive) - pass it via
# -var-file=secrets.auto.tfvars (gitignored) or TF_VAR_jwt_secret env var.
# sendgrid_api_key same story; defaults to "" (SendGrid disabled) until set.
