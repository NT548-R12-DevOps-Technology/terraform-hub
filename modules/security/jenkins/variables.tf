variable "name" {
  description = "Name of the Jenkins security group"
  type        = string
  default     = "jenkins-staging-sg"
}

variable "vpc_id" {
  description = "VPC ID containing the Jenkins nodes"
  type        = string
}

variable "vpn_cidr" {
  description = "CIDR assigned to OpenVPN clients"
  type        = string
}
