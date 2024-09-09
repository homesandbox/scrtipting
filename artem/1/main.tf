# Create a Virtual Cloud Network (VPC)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create a Security Group
module "security_group_allow_ssh" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "allow_ssh"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

   # Ingress rules (allow incoming SSH traffic)
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # Egress rules (allow outgoing traffic)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # -1 allows all protocols
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create a Security Group
module "security_group_allow_rdp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "allow_rdp"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

   # Ingress rules (allow incoming RDP traffic)
  ingress_with_cidr_blocks = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Allow RDP traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # Egress rules (allow outgoing traffic)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"  # -1 allows all protocols
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create a Network ACL for the private subnet
resource "aws_network_acl" "private" {
  vpc_id = module.vpc.vpc_id
  subnet_ids = [module.vpc.private_subnets[0]]

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = module.vpc.public_subnets_cidr_blocks[0]
    from_port  = 0
    to_port    = 65535
    protocol   = "tcp"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
    protocol   = "tcp"
  }

  tags = {
    Name = "private-nacl"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "ssh"
  public_key = file(var.ssh_public_key_path)
}

# Create an EC2 instance
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.5"
  name = "bastion"
  ami           = "ami-09a1c459d70c72b96"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.this.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [
    module.security_group_allow_ssh.security_group_id, 
    module.security_group_allow_rdp.security_group_id
  ]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = "vm-nebo-linux"
  }
}

# Create a Public Windows EC2 instance
resource "aws_instance" "vmnebowindows" {
  ami           = "ami-0a8128f5266cdc447"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [module.security_group_allow_rdp.security_group_id]
  key_name = aws_key_pair.this.key_name
  get_password_data = true

  tags = {
    Name = "vm-nebo-windows"
  }
}

# Create an EC2 instance
module "vmnebolinux" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.5"
  name = "vm-nebo-linux"
  ami           = "ami-09a1c459d70c72b96"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.this.key_name

  associate_public_ip_address = false

  vpc_security_group_ids = [module.security_group_allow_ssh.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = "ec2"
  }
}

output "bastion_public_ip" {
 description = "The public IP of the bastion instance"
 value = module.bastion.public_ip
}

output "vmnebolinux_private_ip" {
 description = "The private IP of vm nebo linux instance"
 value = module.vmnebolinux.private_ip
}

output "vmnebowindows_private_ip" {
 description = "The private IP of vm nebo windows instance"
 value = aws_instance.vmnebowindows.private_ip
}