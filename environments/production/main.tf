# =========================
# Networking
# =========================
module "network" {
  source = "../../modules/network"

  # =========================
  # EKS cluster name (for subnet tags)
  # =========================
  cluster_name = var.cluster_name

  # =========================
  # VPC & Subnet configuration
  # =========================
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

}

# =========================
# Security Groups
# =========================
module "security" {
  source = "../../modules/security"

  # VPC
  vpc_id   = module.network.vpc_id
  vpc_cidr = var.vpc_cidr

  # Admin access
  my_ip_cidr = var.my_ip_cidr

  # EKS private endpoint access from VPN
  enable_eks_support            = true
  eks_cluster_security_group_id = module.eks.eks_cluster_security_group_id
  vpn_cidr                      = var.vpn_cidr
}


# =========================
# SSH Keypair (shared)
# =========================
module "keypair" {
  source = "../../modules/keypair"

  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# =========================
# Observability (reuse)
# =========================
module "observability" {
  source = "../../modules/compute/observability"

  ami                 = var.ami
  instance_type       = var.observability_instance_type
  key_name            = module.keypair.key_name
  subnet_ids          = slice(module.network.private_subnet_ids, 0, 2)
  observability_sg_id = module.security.observability_sg_id
  nodes               = var.observability_nodes
}

# =========================
# OpenVPN (management access)
# =========================
module "openvpn" {
  source = "../../modules/compute/openvpn"

  ami              = var.ami
  instance_type    = var.openvpn_instance_type
  key_name         = module.keypair.key_name
  public_subnet_id = module.network.public_subnet_ids[0]
  openvpn_sg_id    = module.security.openvpn_sg_id
}

# =========================
# Route: Private Subnets → OpenVPN (VPN Gateway)
# =========================
resource "aws_route" "private_to_openvpn" {
  route_table_id         = module.network.private_route_table_id
  destination_cidr_block = var.vpn_cidr
  network_interface_id   = module.openvpn.eni_id
}

# =========================
# IAM for EKS
# =========================
module "iam_eks" {
  source = "../../modules/iam/eks"
  name   = var.cluster_name
}

# =========================
# EKS Cluster (Core)
# =========================
module "eks" {
  source = "../../modules/compute/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  private_subnet_ids = module.network.private_subnet_ids

  cluster_role_arn = module.iam_eks.cluster_role_arn
  node_role_arn    = module.iam_eks.node_role_arn

  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
}

# =========================
# Core EKS Addons
# =========================
module "eks_addons" {
  source       = "../../modules/eks-addons"
  cluster_name = module.eks.cluster_name
}

# =========================
# IAM 
# =========================
module "iam_alb" {
  count  = var.enable_eks_ingress ? 1 : 0
  source = "../../modules/iam/alb"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_issuer_url   = aws_iam_openid_connect_provider.eks.url
}

# =========================
# AWS Load Balancer Controller (Ingress)
# =========================
module "eks_ingress" {
  count  = var.enable_eks_ingress ? 1 : 0
  source = "../../modules/eks-ingress"

  cluster_name            = module.eks.cluster_name
  region                  = var.region
  vpc_id                  = module.network.vpc_id
  alb_controller_role_arn = module.iam_alb[0].alb_controller_role_arn
}
