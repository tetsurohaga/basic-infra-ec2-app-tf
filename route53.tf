#----------------------------------------
# 事前作成済みのホストゾーン 取得
#----------------------------------------
data "aws_route53_zone" "hostzone" {
  name         = "{{ DOMAIN_NAME }}"
  private_zone = false
}

#----------------------------------------
# 東京リージョン分 ACMの認証レコード
#----------------------------------------
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hostzone.zone_id
}

#----------------------------------------
# バージニアリージョン分 ACMの認証レコード
#----------------------------------------
resource "aws_route53_record" "acm_validation_virginia" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert_virginia.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hostzone.zone_id
}

#----------------------------------------
# Cloudfrontとドメインの紐付けレコード
#----------------------------------------
resource "aws_route53_record" "cf_app1" {
  zone_id = data.aws_route53_zone.hostzone.zone_id
  name    = "{{ DOMAIN_NAME }}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app.domain_name
    zone_id                = aws_cloudfront_distribution.app.hosted_zone_id
    evaluate_target_health = true
  }
}