resource "aws_acm_certificate" "acm-resource" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }
