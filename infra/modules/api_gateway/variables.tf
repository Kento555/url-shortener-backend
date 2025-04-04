variable "name" {
  description = "Name for the API Gateway"
  type        = string
}

variable "lambda_post_invoke_arn" {
  description = "Invoke ARN for create-url Lambda"
  type        = string
}

variable "lambda_get_invoke_arn" {
  description = "Invoke ARN for retrieve-url Lambda"
  type        = string
}

variable "custom_domain" {
  description = "Custom domain name (e.g. ce09-avengers-urlshortener.sctp-sandbox.com)"
  type        = string
}

variable "cert_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}
