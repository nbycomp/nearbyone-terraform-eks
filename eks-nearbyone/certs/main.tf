variable "tls_names" {
  default = []
}

resource "aws_acm_certificate" "cert" {

  count = length(var.tls_names)

  domain_name               = var.tls_names[count.index]
  subject_alternative_names = [join(".", ["*", var.tls_names[count.index]])]
  validation_method         = "DNS"

}

data "aws_route53_zone" "zone" {
  count = length(var.tls_names)
  name  = replace(var.tls_names[count.index], "/^[^.]*\\./", "")
}

module "records" {
  source = "./records"
  count  = length(var.tls_names)
  cert   = aws_acm_certificate.cert[count.index]
  zone   = data.aws_route53_zone.zone[count.index]
}
