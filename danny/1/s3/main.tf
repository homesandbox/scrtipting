resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  object_lock_configuration {
    object_lock_enabled = "Enabled"
  }

  lifecycle_rule {
    id      = "mfa-delete"
    enabled = true

    abort_incomplete_multipart_upload_days = 7

    rules {
      id      = "delete-old-objects"
      enabled = true

      filter {
        prefix = ""
      }

      expiration {
        days = 365
      }
    }
  }

  tags = {
    Name = "example-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  ignore_public_acls       = true
  block_public_policy      = true
  restrict_public_buckets  = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
