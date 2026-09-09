# =====================================================
# Kubernetes (k0s) Inventory - Staging
# =====================================================
/* Temporarily disabled with the k0s EC2 instances.
resource "local_file" "kubernetes_inventory" {
  filename = "${var.ansible_inventory_dir}/kubernetes.ini"

  content = <<-EOF
[k0s_controller]
controller ansible_host=${module.k0s.controller.private_ip} ansible_user=ubuntu

[k0s_workers]
%{for idx, inst in module.k0s.workers~}
worker-${idx + 1} ansible_host=${inst.private_ip} ansible_user=ubuntu
%{endfor~}

[k0s_cluster:children]
k0s_controller
k0s_workers
EOF
}
*/

# =====================================================
# Jenkins Inventory - Staging
# =====================================================
moved {
  from = local_file.observability_inventory
  to   = local_file.jenkins_inventory
}

resource "local_file" "jenkins_inventory" {
  filename = "${var.ansible_inventory_dir}/jenkins.ini"

  content = <<-EOF
[jenkins_master]
jenkins-master ansible_host=${module.jenkins.nodes["jenkins_master"].private_ip} ansible_user=ubuntu

[jenkins_workers]
jenkins-worker ansible_host=${module.jenkins.nodes["jenkins_worker"].private_ip} ansible_user=ubuntu

[jenkins_nodes:children]
jenkins_master
jenkins_workers
EOF
}

# =====================================================
# OpenVPN Inventory - Staging
# =====================================================
resource "local_file" "openvpn_inventory" {
  filename = "${var.ansible_inventory_dir}/openvpn.ini"

  content = <<-EOF
[openvpn]
vpn ansible_host=${module.openvpn.public_ip} ansible_user=ubuntu
EOF
}
