# Create S3 Bucket for the static site
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "static-site-bucket-12345"

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = "static-site-bucket-12345"
    Environment = "Dev"
  }

  # Block public access settings to ensure the bucket is not public
  block_public_acls   = true
  block_public_policy = true
}

# Create a CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "example" {
  name                  = "example-oac"
  description           = "OAC for S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior      = "always"
  signing_protocol      = "sigv4"
}

# CloudFront distribution for the static site with OAC
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.s3_bucket.s3_bucket_bucket_domain_name
    origin_id   = module.s3_bucket.s3_bucket_id

    # Attach the OAC to the CloudFront distribution
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for my static site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.s3_bucket.s3_bucket_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "my-static-site-distribution"
    Environment = "Dev"
  }
}

# Add an S3 bucket policy to restrict access only to CloudFront
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service": "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "${module.s3_bucket.s3_bucket_arn}/*",
        Condition = {
          "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
      }
    ]
  })
}

# Output the CloudFront distribution domain name
output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

# Caller identity (used for dynamic account ID resolution)
data "aws_caller_identity" "current" {}
