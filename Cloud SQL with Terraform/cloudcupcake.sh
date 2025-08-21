#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)

# Fetch allowed locations
gcloud org-policies describe constraints/gcp.resourceLocations \
  --project=$PROJECT_ID \
  --format="value(listPolicy.allowedValues)" > allowed_regions.txt

REGION=$(cat allowed_regions.txt | tr -d '[]' | tr ',' '\n' | head -n 1)

if [ -z "$REGION" ]; then
  echo "No allowed region found. Try using 'us' (multi-region)."
  REGION="us"
fi

echo "Using REGION: $REGION"

# Replace region in Terraform variable file
sed -i "s/^  default = .*/  default = \"$REGION\"/" variables.tf

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
