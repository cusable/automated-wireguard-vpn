# main.tf
variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "organization_id" {
  type      = string
  sensitive = true
}

variable "project_id" {
  type      = string
  sensitive = true
}

variable "zone" {
  description = "The Scaleway region to deploy resources"
  default     = "nl-ams-1"
}

variable "instance_type" {
  description = "The type of instance to deploy"
  default     = "STARDUST1-S"
}

variable "wireguard_port" {
  description = "The port WireGuard will listen on"
  default     = 51820
}

variable "image" {
  description = "The name of the image to use for the instance"
  default     = "ubuntu_noble"
}

provider "scaleway" {
  access_key      = var.access_key
  secret_key      = var.secret_key
  organization_id = var.organization_id
  project_id      = var.project_id
  zone            = var.zone
}

resource "scaleway_instance_security_group" "wireguard_sg" {
  name                    = "wireguard-sg"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = "22"
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "TCP"
    port     = "22"
    ip_range = "::/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "UDP"
    port     = var.wireguard_port
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "UDP"
    port     = var.wireguard_port
    ip_range = "::/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "ICMP"
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action   = "accept"
    protocol = "ICMP"
    ip_range = "::/0"
  }
}

resource "random_string" "random_instance_name" {
  length  = 8
  special = false
}

resource "scaleway_instance_ip" "public_ip" {
  # The default value for the type is NAT
  # Enable Routed IPv4
  type = "routed_ipv4"
  # Enable IPv6 with this Parameter
  # type = "routed_ipv6" # Comment out for IPv4, Uncomment for IPv6
}

resource "scaleway_instance_server" "wireguard" {
  name              = "wireguard-${random_string.random_instance_name.result}"
  type              = var.instance_type
  image             = var.image
  security_group_id = scaleway_instance_security_group.wireguard_sg.id
  ip_id             = scaleway_instance_ip.public_ip.id
  tags              = ["wireguard"]

  # Enable IPv6 with this Parameter
  # enable_ipv6     = true # Comment out for IPv4, Uncomment for IPv6

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y ansible",
    ]

    connection {
      type        = "ssh"
      host        = scaleway_instance_ip.public_ip.address
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

output "wireguard_server_ip" {
  value       = scaleway_instance_ip.public_ip.address
  description = "Public IP address of the WireGuard server"
}
