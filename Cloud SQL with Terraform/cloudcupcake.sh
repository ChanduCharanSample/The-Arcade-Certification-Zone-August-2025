#!/bin/bash
set -e

# Detect project
PROJECT_ID=$(gcloud config get-value project)

# Detect allowed regions (Org Policy)
ALLOWED_REGIONS=$(gcloud org-policies describe constraints/gcp.resourceLocations \
  --project="$PROJECT_ID" \
  --format="value(listPolicy.allowedValues)" 2>/dev/null)

# Extract first allowed region
REGION=$(echo "$ALLOWED_REGIONS" | sed 's/,/\n/g' | head -n 1 | sed 's/in://')

# Fallback region
if [[ -z "$REGION" ]]; then
  REGION="us-east1"
fi

echo "Using region: $REGION"

# Clean Terraform state
rm -rf .terraform terraform.tfstate*

# Patch Terraform files
sed -i "s/region *= *\"[a-z0-9-]*\"/region = \"$REGION\"/" *.tf || true
sed -i "s/default *= *\"[a-z0-9-]*\"/default = \"$REGION\"/" *.tf || true

# Initialize & Apply
terraform init -upgrade
terraform plan -out=tfplan -var="region=$REGION"
terraform apply -auto-approve tfplan
