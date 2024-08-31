resource "aws_vpc" "vnet_nebo" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vnet-nebo"
  }
}

resource "aws_subnet" "snet_public" {
  vpc_id            = aws_vpc.vnet_nebo.id
  cidr_block        = "10.0.0.0/17"
  availability_zone = "us-east-1a"  
  map_public_ip_on_launch = true
  tags = {
    Name = "snet-public"
  }
}

resource "aws_subnet" "snet_private" {
  vpc_id            = aws_vpc.vnet_nebo.id
  cidr_block        = "10.0.128.0/17"
  availability_zone = "us-east-1a" 
  tags = {
    Name = "snet-private"
  }
}
