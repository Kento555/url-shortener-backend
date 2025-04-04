variable "name" {
  description = "WAF ACL name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IPv4 CIDRs"
  type        = list(string)
}

variable "api_gw_stage_arn" {
  description = "ARN of the API Gateway stage to associate WAF with"
  type        = string
}
