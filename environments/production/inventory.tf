# =====================================================
# EKS Inventory - Production
# (Replace k0s inventory from staging)
# =====================================================
resource "local_file" "eks_inventory" {
  filename = "${path.root}/../../../ansible/inventories/production/eks.ini"

  content = <<-EOF
# ================================
# EKS Inventory (Production)
# ================================

[eks]
localhost ansible_connection=local

[eks:vars]
eks_cluster_name=${module.eks.cluster_name}
eks_cluster_endpoint=${module.eks.cluster_endpoint}
eks_region=${var.region}
eks_vpc_id=${module.network.vpc_id}

alb_controller_role_arn=${var.enable_eks_ingress ? module.iam_alb[0].alb_controller_role_arn : ""}
EOF
}

# =====================================================
# Observability Inventory - Production
# (Compatible with existing Ansible roles)
# =====================================================
resource "local_file" "observability_inventory" {
  filename = "${path.root}/../../../ansible/inventories/production/observability.ini"

  content = <<-EOF
# ================================
# Observability Inventory (Production)
# ================================

[monitoring]
obser-1 ansible_host=${module.observability.instances[0].private_ip}

[logging]
obser-2 ansible_host=${module.observability.instances[1].private_ip}

[all:vars]
loki_host=${module.observability.instances[1].private_ip}
EOF
}

# =====================================================
# OpenVPN Inventory - Production
# (Compatible with existing Ansible roles)
# =====================================================
resource "local_file" "openvpn_inventory" {
  filename = "${path.root}/../../../ansible/inventories/production/openvpn.ini"

  content = <<-EOF
[openvpn]
vpn ansible_host=${module.openvpn.public_ip}
EOF
}
