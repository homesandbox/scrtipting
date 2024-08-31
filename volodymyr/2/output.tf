output "vpc_id" {
  value = aws_vpc.vnet_nebo.id
}

output "public_subnet_id" {
  value = aws_subnet.snet_public.id
}

output "private_subnet_id" {
  value = aws_subnet.snet_private.id
}

output "vm1_private_ip" {
  value = aws_instance.vm1_private.private_ip
}

output "vm2_public_ip" {
  value = aws_instance.vm2_public.public_ip
}
