# 1. Create working directory
mkdir -p sql-with-terraform
cd sql-with-terraform

# 2. Download Terraform files
gsutil cp -r gs://spls/gsp234/gsp234.zip .

# 3. Unzip contents
unzip -o gsp234.zip

# 4. Update variables.tf with your project ID and allowed region
sed -i 's/project *=.*/project = "qwiklabs-gcp-03-c86dd09f3ca7"/' variables.tf
sed -i 's/region *=.*/region = "us-east1"/' variables.tf

# 5. Initialize Terraform
terraform init

# 6. Create execution plan
terraform plan -out=tfplan

# 7. Apply configuration (auto-approve)
terraform apply -auto-approve tfplan
