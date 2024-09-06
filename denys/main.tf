# Create a Virtual Cloud Network (VPC)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v5.13.0"  

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# Create a Security Group
resource "aws_security_group" "allow_nginx" {
  name        = "allow_nginx"
  description = "Allow NGINX traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_nginx"
  }
}

resource "aws_security_group" "allow_ssm" {
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic for SSM
  }

  tags = {
    Name = "ssm_sg"
  }
}

# IAM assume Role
resource "aws_iam_role" "ec_assume_role" {
  name = "ec2_assume_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

# Attach SSM policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2.instance_profile"
  role = aws_iam_role.ec_assume_role.name
}

# Create an EC2 instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "my-nginx-instance"

  ami           = "ami-066784287e358dad1"
  instance_type = "t2.micro"
  
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  vpc_security_group_ids = [
    aws_security_group.allow_nginx.id,
    aws_security_group.allow_ssm.id
  ]
  subnet_id              = module.vpc.public_subnets[0]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
          EOF

  tags = {
    Name = "my-nginx-instance"
  }
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

# Create a Network ACL
resource "aws_network_acl" "this" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "this-nacl"
  }
}

# Associate NACL with a subnet
resource "aws_network_acl_association" "this" {
  subnet_id     = module.vpc.public_subnets[0]
  network_acl_id = aws_network_acl.this.id
}

# Allow outbound HTTPS traffic to AWS services (SSM requires HTTPS on port 443)
resource "aws_network_acl_rule" "ssm_outbound_https" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"   # Allow outbound traffic to anywhere
  from_port      = 443
  to_port        = 443
}

# Allow outbound DNS (UDP and TCP) traffic for resolving AWS service endpoints
resource "aws_network_acl_rule" "ssm_outbound_dns_udp" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 110
  egress         = true
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "ssm_outbound_dns_tcp" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "web_outbound_tcp" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 130
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


# Allow inbound traffic for established connections (response traffic)
resource "aws_network_acl_rule" "ssm_inbound_established" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow inbound HTTP traffic on port 80
resource "aws_network_acl_rule" "web_inbound_http" {
  network_acl_id = aws_network_acl.this.id
  rule_number    = 210
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Create a Network Firewall Rule Group
resource "aws_networkfirewall_rule_group" "this" {
  capacity = 100
  name     = "vpc-fw-rule-group"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              destination {
                address_definition = "10.0.0.0/16"
              }
              source {
                address_definition = "0.0.0.0/0"
              }
            }
          }
          priority = 1
        }
      }
    }
  }
}


# Create a Network Firewall Policy
resource "aws_networkfirewall_firewall_policy" "this" {
  name = "fw-policy"

  firewall_policy {
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.this.arn
    }

    stateless_default_actions = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}

# Create a Network Firewall
resource "aws_networkfirewall_firewall" "this" {
  name              = "vp-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id            = module.vpc.vpc_id
  subnet_mapping {
    subnet_id = module.vpc.public_subnets[0]
  }
  subnet_mapping {
    subnet_id = module.vpc.public_subnets[1]
  }
  delete_protection = false
  description       = "Network Firewall"
  tags = {
    Name = "vpc-firewall"
  }
}
