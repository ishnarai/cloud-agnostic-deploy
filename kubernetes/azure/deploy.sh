#!/usr/bin/env bash
# =============================================================================
# deploy.sh (Azure)
# =============================================================================
# Deploys the application to an Azure AKS cluster.
#
# Steps:
#   1. Authenticate with Azure
#   2. Configure kubectl
#   3. Render deployment.yaml with the selected Docker image
#   4. Apply Kubernetes manifests
#   5. Wait for rollout
# =============================================================================

set -euo pipefail

FULL_IMAGE="${1:?Usage: ./deploy.sh <full_docker_image>}"

RESOURCE_GROUP="orion-rg"
CLUSTER_NAME="orion-aks-cluster"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================="
echo "Azure Deployment"
echo "========================================="
echo ""

echo "Docker Image"
echo "${FULL_IMAGE}"
echo ""

echo "Obtaining AKS credentials..."

az aks get-credentials \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --overwrite-existing

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
echo "Azure Deployment Successful"
echo "========================================="