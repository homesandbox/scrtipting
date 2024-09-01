
resource "aws_security_group" "ssm_sg" {
  vpc_id = aws_vpc.main_vpc.id

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

# IAM Role
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

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

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}


resource "aws_launch_template" "app_template" {
  name          = "app-launch-template"
  image_id      = "ami-0738e1a0d363b9c7e"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.ssm_sg.id ]
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }
}
