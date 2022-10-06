resource "aws_acm_certificate" "acm-resource" {
  provider          = aws.us_region
  domain_name       = var.domain-name
  validation_method = "DNS"
}
  
resource "aws_cloudfront_origin_access_identity" "cloud-oai" {
  provider          = aws.us_region
  comment           = var.bucket-name
}  

resource "aws_s3_bucket" "my-bucket" {
  provider          = aws.us_region
  bucket            = var.bucket-name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  provider          = aws.us_region
  bucket            = aws_s3_bucket.my-bucket.id
  acl               = "private"
}
  
resource "aws_s3_bucket_public_access_block" "s3-bucket-public" {
  provider                = aws.us_region
  bucket                  = aws_s3_bucket.my-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}  

data "aws_iam_policy_document" "bucket-policy" {
  provider        = aws.us_region
  statement {
    principals {
      type        = "AWS"
      identifiers = ["aws_cloudfront_origin_access_identity.cloud-oai.iam.arn"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

resources = ["${aws_s3_bucket.my-bucket.arn}/*"]
  }
}  

resource "aws_s3_bucket_policy" "bucket_policy" {
  provider          = aws.us_region
  bucket            = aws_s3_bucket.my-bucket.id
  policy            = data.aws_iam_policy_document.bucket-policy.json
}
  
resource "aws_cloudfront_distribution" "s3_distribution" {
  provider          = aws.us_region
  origin {
    domain_name = aws_s3_bucket.my-bucket.bucket_regional_domain_name
    origin_id   = var.bucket-name

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.cloud-oai.id}"
    }
  }  
  
aliases = ["mysite.example.com"]  
  
default_root_object = "index.html"

enabled = true
  
default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.bucket-name
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
}  
 
 resource "aws_route53_zone" "primary" {
  provider          = aws.us_region 
  name              = "www.sk-aws.com"
}
  
resource "aws_route53_record" "www" {
  provider          = aws.us_region
  zone_id           = aws_route53_zone.primary.zone_id
  name              = "www.skazure.com"
  type              = "A"
}  
  
