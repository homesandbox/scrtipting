resource "aws_efs_file_system" "example" {
  creation_token = "my-efs"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "example-efs"
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.private.id
  security_groups = [aws_security_group.storage_sg.id]
}
