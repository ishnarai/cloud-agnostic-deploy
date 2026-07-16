#!/usr/bin/env bash
# =============================================================================
# deploy.sh (AWS)
# =============================================================================
# Deploys the application to an AWS EKS cluster.
#
# Steps:
#   1. Authenticate with AWS
#   2. Configure kubectl
#   3. Render deployment.yaml with the selected Docker image
#   4. Apply Kubernetes manifests
#   5. Wait for rollout
# =============================================================================

set -euo pipefail

FULL_IMAGE="${1:?Usage: ./deploy.sh <full_docker_image>}"

AWS_REGION="ap-south-1"
CLUSTER_NAME="orion-eks-cluster"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "========================================="
echo "AWS Deployment"
echo "========================================="
echo ""

echo "Docker Image"
echo "${FULL_IMAGE}"
echo ""

echo "Updating kubeconfig..."

aws eks update-kubeconfig \
  --region "${AWS_REGION}" \
  --name "${CLUSTER_NAME}"

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
echo "Waiting for rollout..."

kubectl rollout status deployment/orion-deployment --timeout=180s

rm -f "${SCRIPT_DIR}/deployment-rendered.yaml"

echo ""
echo "========================================="
echo "AWS Deployment Successful"
echo "========================================="