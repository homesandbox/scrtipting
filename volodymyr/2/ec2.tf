resource "aws_instance" "vm2_public" {
  ami           = "ami-0738e1a0d363b9c7e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.snet_public.id
  security_groups = [aws_security_group.public_sg.id]
  tags = {
    Name = "VM2-Public"
  }
  depends_on = [ aws_security_group.public_sg ]
}

resource "aws_instance" "vm1_private" {
  ami           = "ami-0738e1a0d363b9c7e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.snet_private.id
  security_groups = [aws_security_group.private_sg.id]
  tags = {
    Name = "VM1-Private"
  }
  depends_on = [ aws_security_group.private_sg ]
}
