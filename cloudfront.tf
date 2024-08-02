#----------------------------------------
# Cloudfront ディストリビューション
#----------------------------------------
resource "aws_cloudfront_distribution" "app" {
  aliases = ["{{ DOMAIN_NAME }}"]
  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    target_origin_id = "app-alb"
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    domain_name              = aws_lb.alb_app.dns_name
    origin_id                = "app-alb"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }  

  price_class = "PriceClass_200"

  tags = {
    Name = "distribution_app1"
  }

  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.acm_cert_virginia.arn
    ssl_support_method              = "sni-only"
    minimum_protocol_version        = "TLSv1.2_2021"
    cloudfront_default_certificate  = false
  }
}
