#----------------------------------------
# 東京リージョン分 ACM証明書 
#----------------------------------------
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "{{ DOMAIN_NAME }}"
  validation_method = "DNS"

  tags = {
    Name = "acm_alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#----------------------------------------
# 東京リージョン分 ACM証明書 認証
#----------------------------------------
resource "aws_acm_certificate_validation" "acm_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

#----------------------------------------
# バージニアリージョン分 ACM証明書 
#----------------------------------------
resource "aws_acm_certificate" "acm_cert_virginia" {
  provider          = aws.virginia
  domain_name       = "{{ DOMAIN_NAME }}"
  validation_method = "DNS"

  tags = {
    Name = "acm_cloudfront"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#----------------------------------------
# バージニアリージョン分 ACM証明書 認証
#----------------------------------------
resource "aws_acm_certificate_validation" "acm_validation_virginia" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.acm_cert_virginia.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation_virginia : record.fqdn]
}
