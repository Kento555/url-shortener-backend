resource "aws_acm_certificate" "this" {
  domain_name       = var.custom_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "dev"
    Project     = "url-shortener"
  }
}

resource "aws_route53_record" "custom_domain_validation" {
  for_each = {
    for dvo in tolist(aws_acm_certificate.this.domain_validation_options) :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}


resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.custom_domain_validation : record.fqdn]
}

resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = var.custom_domain
  type    = "A"

  alias {
    name                   = var.regional_domain_name
    zone_id                = var.regional_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}
