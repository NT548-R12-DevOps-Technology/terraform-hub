resource "aws_security_group" "this" {
  name        = var.name
  description = "Security group for Jenkins controller and workers"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH administration from VPN clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]
  }

  ingress {
    description = "Jenkins dashboard from VPN clients"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]
  }

  ingress {
    description = "SSH between Jenkins controller and workers"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
