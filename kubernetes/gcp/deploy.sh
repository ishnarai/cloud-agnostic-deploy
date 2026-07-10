#!/usr/bin/env bash
# =============================================================================
# deploy.sh (GCP)
# =============================================================================
# Usage: ./deploy.sh <image_tag> <gcp_project_id>

set -euo pipefail

IMAGE_TAG="${1:?Usage: ./deploy.sh <image_tag> <gcp_project_id>}"
GCP_PROJECT_ID="${2:?Usage: ./deploy.sh <image_tag> <gcp_project_id>}"
CLUSTER_NAME="orion-gke-cluster"
GCP_ZONE="asia-south1-a"

echo ">> Configuring kubectl for GKE cluster: ${CLUSTER_NAME}"
gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "${GCP_ZONE}" --project "${GCP_PROJECT_ID}"

echo ">> Applying Kubernetes manifests"
kubectl apply -f "$(dirname "$0")/deployment.yaml"
kubectl apply -f "$(dirname "$0")/service.yaml"
kubectl apply -f "$(dirname "$0")/ingress.yaml"

echo ">> Setting image to: ${IMAGE_TAG}"
kubectl set image deployment/orion-deployment orion-app="${IMAGE_TAG}"

echo ">> Waiting for rollout to complete"
kubectl rollout status deployment/orion-deployment --timeout=120s

echo ">> Deployment complete."
