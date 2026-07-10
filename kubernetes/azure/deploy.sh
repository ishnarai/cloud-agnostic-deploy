#!/usr/bin/env bash
# =============================================================================
# deploy.sh (Azure)
# =============================================================================
# Usage: ./deploy.sh <image_tag>

set -euo pipefail

IMAGE_TAG="${1:?Usage: ./deploy.sh <image_tag>}"
CLUSTER_NAME="orion-aks-cluster"
RESOURCE_GROUP="orion-rg"

echo ">> Configuring kubectl for AKS cluster: ${CLUSTER_NAME}"
az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${CLUSTER_NAME}" --overwrite-existing

echo ">> Applying Kubernetes manifests"
kubectl apply -f "$(dirname "$0")/deployment.yaml"
kubectl apply -f "$(dirname "$0")/service.yaml"
kubectl apply -f "$(dirname "$0")/ingress.yaml"

echo ">> Setting image to: ${IMAGE_TAG}"
kubectl set image deployment/orion-deployment orion-app="${IMAGE_TAG}"

echo ">> Waiting for rollout to complete"
kubectl rollout status deployment/orion-deployment --timeout=120s

echo ">> Deployment complete."
