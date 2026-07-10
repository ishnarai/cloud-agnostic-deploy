# cloud-agnostic-deploy

The **deployment repository** for the Orion cloud-agnostic PoC. This repository owns all infrastructure (Terraform) and orchestration (Kubernetes manifests, deployment scripts, CD pipeline) for AWS, Azure, and GCP. It contains **no application source code** — it only knows how to take an already-built Docker image (produced by [`cloud-agnostic-app`](../cloud-agnostic-app)) and run it on whichever cloud is selected.

## Repository structure

```
cloud-agnostic-deploy/
├── .github/workflows/
│   ├── terraform.yml    # Reusable: provisions infra for one cloud
│   ├── deploy.yml         # Reusable: deploys an image to one cloud's cluster
│   └── cd.yml               # Orchestrator: terraform.yml -> deploy.yml
├── terraform/
│   ├── aws/                  # Provisions EKS
│   ├── azure/                # Provisions AKS
│   ├── gcp/                  # Provisions GKE
│   └── modules/common/    # Shared naming/tagging module used by all three
├── kubernetes/
│   ├── aws/       deployment.yaml, service.yaml, ingress.yaml (ALB), deploy.sh
│   ├── azure/     deployment.yaml, service.yaml, ingress.yaml (App Gateway), deploy.sh
│   └── gcp/       deployment.yaml, service.yaml, ingress.yaml (GCE), deploy.sh
├── scripts/
│   └── validate-cloud-provider.sh
├── .env.example
└── README.md
```

## Why Kubernetes manifests are per-cloud here (not shared)

In the original single-repo PoC, `k8s/` had one shared `deployment.yaml`/`service.yaml`. Here, each cloud gets its own folder because `ingress.yaml` is **genuinely** cloud-specific — routing external traffic in requires AWS's ALB Ingress Controller annotations, Azure's Application Gateway Ingress Controller annotations, or GKE's native GCE ingress class, none of which are interchangeable. Rather than pretending this file could be unified, each cloud's folder holds its complete, self-contained manifest set — `deployment.yaml` and `service.yaml` remain byte-for-byte identical across folders, proving the application layer stays untouched; only `ingress.yaml` differs.

## The CD pipeline

Two ways `cd.yml` can start:

1. **Automatic**: the `cloud-agnostic-app` repo's CI dispatches an `app-image-built` event here the moment a new image lands on `main`. Defaults to deploying to AWS.
2. **Manual**: trigger `cd.yml` yourself from the Actions tab, choosing the cloud (`aws`/`azure`/`gcp`) and image tag explicitly — this is the primary way to demo cloud-switching.

Either way, `cd.yml` calls:
1. `terraform.yml` — provisions/updates that cloud's cluster.
2. `deploy.yml` — authenticates to that cloud, then runs the matching `kubernetes/<cloud>/deploy.sh`, which applies manifests, sets the image, and waits for rollout.

## Manual deployment (without CI/CD)

```bash
cd terraform/aws        # or azure, or gcp
terraform init
terraform apply

cd ../../kubernetes/aws
./deploy.sh ghcr.io/your-org/cloud-agnostic-app:latest
```

## Switching cloud providers

Run the CD workflow manually and select a different value from the `cloud_provider` dropdown. No file in this repository needs to be edited — the dropdown selection alone determines which Terraform folder and which `kubernetes/<cloud>/` folder get used.

## Required GitHub Secrets (this repository)

| Secret | Used by | Purpose |
|---|---|---|
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | terraform.yml, deploy.yml | AWS authentication |
| `AZURE_CREDENTIALS` | terraform.yml, deploy.yml | Azure service principal JSON |
| `GCP_SA_KEY` | terraform.yml, deploy.yml | GCP service account JSON key |
| `GCP_PROJECT_ID` | terraform.yml, deploy.yml | GCP project targeting (no default exists) |

## Cost warning

EKS/AKS/GKE clusters incur charges the moment they exist. Run `terraform destroy` in the relevant `terraform/<cloud>/` folder when you're done demoing.
