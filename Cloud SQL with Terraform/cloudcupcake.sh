#!/bin/bash
# Automate Cloud SQL Instance Creation using Terraform (GSP234)
# Author: ChatGPT

set -e  # Exit on error

# === VARIABLES ===
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region)

# If region is not set in gcloud config, set a default
if [ -z "$REGION" ]; then
  REGION="us-central1"
fi

# === TASK 1: Setup Directory and Fetch Files ===
echo "Creating working directory..."
mkdir -p sql-with-terraform
cd sql-with-terraform

echo "Fetching Terraform scripts..."
gsutil cp -r gs://spls/gsp234/gsp234.zip .

echo "Unzipping files..."
unzip -o gsp234.zip
cd gsp234

# === TASK 2: Update variables.tf ===
echo "Updating variables.tf with Project ID and Region..."
sed -i "s/project[[:space:]]*=.*/project = \"$PROJECT_ID\"/" variables.tf
sed -i "s/region[[:space:]]*=.*/region = \"$REGION\"/" variables.tf

# === TASK 3: Initialize and Apply Terraform ===
echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan -out=tfplan

echo "Applying Terraform configuration..."
terraform apply -auto-approve tfplan

echo "Terraform apply completed!"
terraform output
