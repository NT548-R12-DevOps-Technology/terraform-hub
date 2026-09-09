# =========================
# OUTPUTS
# =========================

# ================================
# OpenVPN
# ================================
output "openvpn_public_ip" {
  value = module.openvpn.public_ip
}

# ================================
# k0s Cluster
# ================================
/* Temporarily disabled with the k0s EC2 instances.
output "k0s_controller_private_ip" {
  value = module.k0s.controller.private_ip
}

output "k0s_workers_private_ips" {
  value = [for w in module.k0s.workers : w.private_ip]
}
*/

# ================================
# Jenkins
# ================================
output "jenkins_private_ips" {
  value = [for node in module.jenkins.instances : node.private_ip]
}

# ================================
# Application Load Balancers
# ================================
/* Temporarily disabled with the load balancers.
output "kubernetes_alb_dns_name" {
  value = module.kubernetes_alb.alb_dns_name
}

output "observability_alb_dns_name" {
  value = module.observability_alb.alb_dns_name
}
*/
