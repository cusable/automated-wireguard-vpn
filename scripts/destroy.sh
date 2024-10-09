#!/bin/bash

set -e

# Change to the terraform directory
cd ../terraform

# Get the public IP of the instance (same as used in the deploy script)
INSTANCE_IP=$(terraform output -raw wireguard_server_ip)

# Remove the server IP from the known_hosts file
if [ -n "$INSTANCE_IP" ]; then
    echo "Removing $INSTANCE_IP from known_hosts..."
    ssh-keygen -R "$INSTANCE_IP"
else
    echo "Instance IP not found. Skipping known_hosts cleanup."
fi

# Destroy the Terraform-managed infrastructure
terraform destroy -auto-approve

# Clean up generated files
cd ../ansible

rm -rf config
rm -rf keys
rm -f inventory
