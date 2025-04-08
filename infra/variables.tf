variable "acm_cert_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses for WAF"
  type        = list(string)
}

variable "custom_domain" {
  description = "Custom domain name for API Gateway"
  type        = string
}
