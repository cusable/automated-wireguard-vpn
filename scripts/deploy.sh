#!/bin/bash

set -e

# Change to the terraform directory
cd ../terraform

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

# Get the public IP of the instance
INSTANCE_IP=$(terraform output -raw wireguard_server_ip)

# Export the instance IP as an environment variable for Ansible
export WIREGUARD_SERVER_IP=$INSTANCE_IP

# Change to the ansible directory
cd ../ansible

# Create an inventory file dynamically
echo "[wireguard]" > inventory
echo "$INSTANCE_IP ansible_user=root" >> inventory

# Wait for SSH to become available
echo "Waiting for SSH to become available on ${INSTANCE_IP}..."
until ssh -oStrictHostKeyChecking=no -oConnectTimeout=5 root@${INSTANCE_IP} 'echo SSH is up' &>/dev/null; do
  sleep 5
done

mkdir -p config
mkdir -p keys

# Generate ULA IPv6 Prefix
generate_ula_ipv6() {
  prefix="fd$(openssl rand -hex 1):$(openssl rand -hex 2):$(openssl rand -hex 2)"
  echo $prefix
}

ULA_PREFIX=$(generate_ula_ipv6)
echo "Generated ULA Prefix: ${ULA_PREFIX}"

# Run the Ansible playbook
ansible-playbook -i inventory playbooks/wireguard.yml -e "wireguard_server_ip=${INSTANCE_IP} ula_prefix=${ULA_PREFIX}"

# Output the client configuration
echo "Client configuration generated at ansible/config/client.conf"
