# =========================
# AWS & Global
# =========================
variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpn_cidr" {
  type        = string
  description = "OpenVPN client subnet CIDR"
}

# =========================
# SSH
# =========================
variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

# =========================
# Ansible
# =========================
variable "ansible_inventory_dir" {
  type        = string
  description = "Base directory for Ansible inventories"
}

# =========================
# VPC and AZ
# =========================
variable "az_count" {
  type = number

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3"
  }
}


variable "subnet_newbits" {
  type        = number
  description = "Subnet newbits for CIDR calculation"
}

variable "public_subnet_indexes" {
  type = list(number)

  validation {
    condition     = length(var.public_subnet_indexes) == 3
    error_message = "public_subnet_indexes must contain exactly 3 indexes."
  }
}

variable "k8s_subnet_indexes" {
  type = list(number)

  validation {
    condition     = length(var.k8s_subnet_indexes) == 3
    error_message = "k8s_subnet_indexes must contain exactly 3 indexes."
  }
}

variable "observ_subnet_indexes" {
  type = list(number)

  validation {
    condition     = length(var.observ_subnet_indexes) == 3
    error_message = "observ_subnet_indexes must contain exactly 3 indexes."
  }
}

variable "openvpn_public_subnet_index" {
  type = number
}

variable "k0s_nodes" {
  description = "Static placement plan for the staging k0s nodes"
  type = map(object({
    subnet_index = number
    private_ip   = string
  }))

  validation {
    condition = (
      length(var.k0s_nodes) == 4 &&
      alltrue([
        for key in ["master", "worker1", "worker2", "worker3"] :
        contains(keys(var.k0s_nodes), key)
      ]) &&
      alltrue([
        for node in values(var.k0s_nodes) :
        node.subnet_index >= 0 && node.subnet_index < 3
      ])
    )
    error_message = "k0s_nodes must define master, worker1, worker2, worker3 and each subnet_index must be between 0 and 2."
  }
}

variable "observability_nodes" {
  description = "Static placement plan for the Jenkins nodes enabled in the first provisioning phase"
  type = map(object({
    subnet_index = number
    private_ip   = string
  }))

  validation {
    condition = (
      length(var.observability_nodes) == 2 &&
      alltrue([
        for key in ["jenkins_master", "jenkins_worker"] :
        contains(keys(var.observability_nodes), key)
      ]) &&
      alltrue([
        for node in values(var.observability_nodes) :
        node.subnet_index >= 0 && node.subnet_index < 3
      ])
    )
    error_message = "observability_nodes must define jenkins_master and jenkins_worker; each subnet_index must be between 0 and 2."
  }
}



# =========================
# Compute - STAGING
# =========================

# k0s cluster
variable "k0s_instance_type" {
  type        = string
  description = "Instance type for k0s controller & workers"
}

# Observability nodes
variable "observability_instance_type" {
  type        = string
  description = "Instance type for monitoring and platform service nodes"
}

# OpenVPN
variable "openvpn_instance_type" {
  type        = string
  description = "Instance type for OpenVPN server"
}

# =========================
# Application Load Balancer
# =========================
variable "alb_target_port" {
  type        = number
  description = "Target port for ALB (NodePort / Ingress)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}
