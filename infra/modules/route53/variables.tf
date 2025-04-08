variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "custom_domain" {
  description = "Custom domain name for the API Gateway"
  type        = string
}

variable "regional_domain_name" {
  description = "Regional domain name from API Gateway"
  type        = string
}

variable "regional_zone_id" {
  description = "Regional zone ID from API Gateway"
  type        = string
}
