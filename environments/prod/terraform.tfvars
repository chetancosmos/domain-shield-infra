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

# No custom domain for this POC yet, so alerts come from a personal Gmail
# address verified in SendGrid via Single Sender Verification.
sendgrid_from_email = "chetan15cosmos@gmail.com"

# Permanently on: scans running under cpu_idle=true were observed to hang
# indefinitely (not just slow down) once the Pub/Sub ack response completes
# and CPU gets throttled mid-background-task, with no automatic retry since
# the message is already acked. Reliability over the small extra always-on
# cost - see modules/cloud-run's cpu_idle description.
worker_always_on = true
