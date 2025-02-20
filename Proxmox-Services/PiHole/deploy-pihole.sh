#!/bin/bash

# Exit on errors
set -e  

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Try using sudo."
    exit 1
fi

# Define Terraform directory
TERRAFORM_DIR="./"

# Navigate to the Terraform directory
cd "$TERRAFORM_DIR"

echo "[*] Initializing Terraform..."
terraform init

echo "[*] Planning Terraform deployment..."
if ! terraform plan -out=tfplan; then
    echo "[!] Terraform plan failed. Exiting."
    exit 1
fi

echo "[*] Applying Terraform changes..."
terraform apply -auto-approve tfplan

echo -e "[*] Terraform Completed."
echo -e "[*] Waiting for container deployment..."

# Wait for container deployment
sleep 5 

echo "[*] Running Ansible playbook..."
ansible-playbook -i inventory.ini pihole.yml -K
