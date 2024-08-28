provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "default" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "vm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.default.key_name

  # Security group to allow SSH access
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "LinuxVM"
  }
}

# Create a security group that allows SSH access
resource "aws_security_group" "ssh" {
  name_prefix = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh"
  }
}
