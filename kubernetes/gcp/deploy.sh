#!/usr/bin/env bash
# =============================================================================
# deploy.sh (GCP)
# =============================================================================
# Deploys the application to a Google GKE cluster.
#
# Steps:
#   1. Authenticate with Google Cloud
#   2. Configure kubectl
#   3. Render deployment.yaml with the selected Docker image
#   4. Apply Kubernetes manifests
#   5. Wait for rollout
# =============================================================================

set -euo pipefail

FULL_IMAGE="${1:?Usage: ./deploy.sh <full_docker_image> <project_id>}"
PROJECT_ID="${2:?Usage: ./deploy.sh <full_docker_image> <project_id>}"

ZONE="asia-south1-a"
CLUSTER_NAME="orion-gke-cluster"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================="
echo "Google Cloud Deployment"
echo "========================================="
echo ""

echo "Docker Image"
echo "${FULL_IMAGE}"
echo ""

echo "Obtaining GKE credentials..."

gcloud container clusters get-credentials \
    "${CLUSTER_NAME}" \
    --zone "${ZONE}" \
    --project "${PROJECT_ID}"

echo ""
echo "Rendering Kubernetes manifest..."

sed \
  "s|IMAGE_PLACEHOLDER|${FULL_IMAGE}|g" \
  "${SCRIPT_DIR}/deployment.yaml" \
  > "${SCRIPT_DIR}/deployment-rendered.yaml"

echo ""
echo "Applying manifests..."

kubectl apply -f "${SCRIPT_DIR}/deployment-rendered.yaml"
kubectl apply -f "${SCRIPT_DIR}/service.yaml"
kubectl apply -f "${SCRIPT_DIR}/ingress.yaml"

echo ""
echo "Waiting for deployment rollout..."

kubectl rollout status deployment/orion-deployment --timeout=180s

rm -f "${SCRIPT_DIR}/deployment-rendered.yaml"

echo ""
echo "========================================="
echo "Google Cloud Deployment Successful"
echo "========================================="