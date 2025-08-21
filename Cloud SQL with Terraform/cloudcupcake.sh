#!/bin/bash
set -e

# Detect project
PROJECT_ID=$(gcloud config get-value project)

# Get allowed regions from Org Policy
ALLOWED_REGIONS=$(gcloud org-policies describe constraints/gcp.resourceLocations \
  --project="$PROJECT_ID" \
  --format="value(listPolicy.allowedValues)" 2>/dev/null)

# Extract first allowed region (remove 'in:' prefix)
REGION=$(echo "$ALLOWED_REGIONS" | sed 's/,/\n/g' | head -n 1 | sed 's/in://')

if [[ -z "$REGION" ]]; then
  echo "No allowed region found, defaulting to us-east1"
  REGION="us-east1"
fi

echo "Using region: $REGION"

# Patch main.tf to use var.region instead of hardcoded region
sed -i 's/region *= *"us-[a-z0-9-]*"/region = var.region/' main.tf || true

# Patch variables.tf default region
sed -i "s/default *= *\"us-[a-z0-9-]*\"/default = \"$REGION\"/" variables.tf || true

# Terraform init & apply
terraform init -upgrade
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
