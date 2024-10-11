# Automated WireGuard VPN Deployment

This repository automates the deployment and configuration of a **WireGuard VPN server** on **Scaleway Cloud** using **Terraform** and **Ansible**. It provides a fully automated solution for setting up, configuring, and managing WireGuard VPN instances, complete with dynamic configuration generation and simple deployment scripts.

## Features

- Infrastructure provisioning with **Terraform**
- Automated WireGuard configuration using **Ansible**
- Jinja2 templates for dynamic VPN configuration
- Scripts for quick deployment and teardown of infrastructure

## Quick Start

1. Clone the repository:
``` bash
git clone https://github.com/cusable/automated-wireguard-vpn.git
cd automated-wireguard-vpn
```
2. Set your **Scaleway credentials** in `scaleway.auto.tfvars`.
3. Deploy the infrastructure:
``` bash
cd scripts
./deploy.sh
```

For a more in-depth guide on the setup and technical details, please refer to the [full article](https://cusable.com/posts/automated-wireguard-vpn/).

## Requirements

- Terraform
- Ansible
- Scaleway Cloud account

## License

MIT License
