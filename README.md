# domain-shield-infra

Terraform for DomainShield's GCP footprint. Sized as a **cost-conscious POC for a
handful of users** (3-4), not production scale — see "Cost notes" below before
bumping anything up.

## Layout

```
modules/
  network/             VPC, subnet, private-services peering (no VPC connector)
  cloudsql/             Cloud SQL Postgres 15, private IP only
  memorystore/          Redis 7, private IP only
  pubsub/                scan-jobs topic + push subscription + DLQ
  artifact-registry/    Docker repo for api/worker images
  secrets/                generic Secret Manager wrapper
  cloud-run/             reusable module, instantiated once for api, once for worker
  storage/               GCS bucket for screenshots (replaces local static/ folder)
environments/
  prod/                  root module wiring everything together for the single environment
```

## Prerequisites

1. `gcloud auth application-default login` (or a service account key) with permissions
   on project `project-e81a57d7-c451-4010-8d6`.
2. A GCS bucket for Terraform state, created once by hand (chicken-and-egg — Terraform
   can't create the bucket it stores its own state in):
   ```
   gsutil mb -p project-e81a57d7-c451-4010-8d6 -l asia-south1 gs://project-e81a57d7-c451-4010-8d6-tfstate
   gsutil versioning set on gs://project-e81a57d7-c451-4010-8d6-tfstate
   ```
3. Install/authorize the "Google Cloud Build" GitHub App on the app repo (Console →
   Cloud Build → Triggers → Connect Repository). Required once before
   `google_cloudbuild_trigger.backend_deploy` can apply.
4. Fill in `github_owner` / `github_repo_name` in `environments/prod/terraform.tfvars`
   once the app repo exists on GitHub.
5. A `secrets.auto.tfvars` (gitignored) with the sensitive vars:
   ```hcl
   jwt_secret       = "..."   # openssl rand -hex 32
   sendgrid_api_key = "..."   # optional, leave "" to disable email
   ```

## Usage

```
cd environments/prod
terraform init
terraform plan    # review before ever applying
terraform apply   # only when you're ready to spend real money
```

## Design notes

- **No Serverless VPC Access connector.** Cloud Run uses Direct VPC Egress
  (`vpc_access.network_interfaces`) to reach Cloud SQL/Memorystore over private IP.
  A connector's always-on VMs cost ~$8-10/month regardless of traffic; direct egress
  has no idle cost, which matters more than the marginal latency difference at this
  scale.
- **Cloud Run images bootstrap with a public placeholder** (`us-docker.pkg.dev/cloudrun/container/hello`)
  so the very first `terraform apply` succeeds before any image has been pushed to
  Artifact Registry. `lifecycle.ignore_changes` on the image means Terraform never
  fights with Cloud Build over the deployed image after that — Cloud Build owns
  deploys from then on.
- **Pub/Sub push subscription targets the worker's Cloud Run URL directly**
  (`module.cloud_run_worker.url`), so Terraform resolves the URL and wires the
  subscription in a single `apply` — no manual two-phase bootstrap needed.
- **Both api and worker default to `min_instance_count = 0`** (scale-to-zero). Cold
  starts are an acceptable tradeoff for 3-4 users; revisit if latency complaints show up.

## Cost notes (POC sizing — revisit before onboarding real customers)

| Resource | POC default | Why |
|---|---|---|
| Cloud SQL | `db-f1-micro`, ZONAL, no PITR | Cheapest supported Postgres tier; fine until concurrent load shows up |
| Memorystore | `BASIC` tier, 1GB | No HA, no failover — acceptable for a POC cache |
| Cloud Run (api/worker) | `min_instance_count = 0`, 1 vCPU / 512Mi | Scale-to-zero; pay only for actual requests |
| Networking | Direct VPC Egress, no connector | Removes ~$8-10/mo fixed connector cost |

Recurring costs you can't avoid even at zero traffic: Cloud SQL instance (even
`db-f1-micro`), Memorystore instance, and the tfstate bucket (negligible). Cloud Run,
Pub/Sub, Secret Manager, and Artifact Registry storage are usage-based and stay near
zero for a handful of users.
