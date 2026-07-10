#!/usr/bin/env bash
# =============================================================================
# deploy.sh (AWS)
# =============================================================================
# Deploys the application to the EKS cluster provisioned by terraform/aws/.
# Called by the CD pipeline (deploy.yml), but also runnable manually by a
# human for local/manual deployments - a real enterprise convenience: the
# pipeline and a human should be able to run the EXACT same script and get
# the exact same result, rather than the pipeline having undocumented logic
# that only exists inline in YAML.
#
# Usage: ./deploy.sh <image_tag>
# Example: ./deploy.sh ghcr.io/yourorg/cloud-agnostic-app:abc1234

set -euo pipefail
# -e: exit immediately if any command fails
# -u: treat unset variables as errors
# -o pipefail: a pipeline fails if ANY command in it fails, not just the last

IMAGE_TAG="${1:?Usage: ./deploy.sh <image_tag>}"
CLUSTER_NAME="orion-eks-cluster"
AWS_REGION="ap-south-1"

echo ">> Configuring kubectl for EKS cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"

echo ">> Applying Kubernetes manifests"
kubectl apply -f "$(dirname "$0")/deployment.yaml"
kubectl apply -f "$(dirname "$0")/service.yaml"
kubectl apply -f "$(dirname "$0")/ingress.yaml"

echo ">> Setting image to: ${IMAGE_TAG}"
kubectl set image deployment/orion-deployment orion-app="${IMAGE_TAG}"

echo ">> Waiting for rollout to complete"
kubectl rollout status deployment/orion-deployment --timeout=120s

echo ">> Deployment complete."
