#!/usr/bin/env bash
# =============================================================================
# validate-cloud-provider.sh
# =============================================================================
# Shared helper used by CI/CD workflows and humans alike to validate that
# CLOUD_PROVIDER is one of the three supported values before doing anything
# destructive (Terraform apply, kubectl apply). Fails loudly and immediately
# on an invalid value, rather than letting a typo silently reach Terraform.
#
# Usage: ./validate-cloud-provider.sh <value>

set -euo pipefail

PROVIDER="${1:?Usage: ./validate-cloud-provider.sh <aws|azure|gcp>}"

case "$PROVIDER" in
  aws|azure|gcp)
    echo "Valid cloud provider: $PROVIDER"
    ;;
  *)
    echo "ERROR: Invalid CLOUD_PROVIDER '$PROVIDER'. Must be one of: aws, azure, gcp" >&2
    exit 1
    ;;
esac
