variable "acm_cert_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}
