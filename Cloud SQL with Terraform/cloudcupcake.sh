#!/bin/bash
# Automate Cloud SQL Instance Creation using Terraform (GSP234)

set -e  # Exit immediately on error

PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region)
if [ -z "$REGION" ]; then
  REGION="us-central1"
fi

echo "Creating working directory..."
mkdir -p sql-with-terraform
cd sql-with-terraform

echo "Fetching Terraform scripts..."
gsutil cp -r gs://spls/gsp234/gsp234.zip .

echo "Unzipping files..."
unzip -o gsp234.zip

echo "Updating variables.tf with Project ID and Region..."
sed -i "s/project[[:space:]]*=.*/project = \"$PROJECT_ID\"/" variables.tf
sed -i "s/region[[:space:]]*=.*/region = \"$REGION\"/" variables.tf

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan -out=tfplan

echo "Applying Terraform configuration..."
terraform apply -auto-approve tfplan

echo "Terraform apply completed!"
terraform output
