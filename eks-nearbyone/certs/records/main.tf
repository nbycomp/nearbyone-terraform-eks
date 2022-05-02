variable "cert" {}
variable "zone" {}

resource "aws_route53_record" "record" {
  for_each = {
    for dvo in var.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = var.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}
